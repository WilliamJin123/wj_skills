#!/usr/bin/env node
// Shots of real pages at 390 and 1280, light and dark, each with stageshow's box-fit check.
// Run from the project folder: Playwright resolves from there.
import { mkdirSync, readdirSync, writeFileSync } from 'node:fs'
import { createRequire } from 'node:module'
import { homedir, tmpdir } from 'node:os'
import { join } from 'node:path'
import { pathToFileURL } from 'node:url'
import { parseArgs } from 'node:util'

const { values: o, positionals: urls } = parseArgs({
  allowPositionals: true,
  options: {
    widths: { type: 'string', default: '390,1280' },
    looks: { type: 'string', default: 'light,dark' },
    'dark-param': { type: 'string' },
    'dark-js': { type: 'string' },
    'light-param': { type: 'string' },
    'light-js': { type: 'string' },
    select: { type: 'string', default: 'body' },
    wait: { type: 'string', default: '800' },
    height: { type: 'string', default: '900' },
    full: { type: 'boolean', default: false },
    out: { type: 'string', default: join(tmpdir(), 'ui-shots') },
    stageshow: { type: 'string', default: process.env.STAGESHOW_DIR ?? join(homedir(), '.claude/skills/stageshow') },
  },
})
if (!urls.length) {
  console.error('usage: shoot.mjs <url>... [--widths 390,1280] [--looks light,dark] [--dark-param k=v] [--dark-js js] [--select main] [--full] [--out dir]')
  process.exit(2)
}

// a pnpm workspace keeps Playwright under a package, not the root: try those too
const pnpm = join(process.cwd(), 'node_modules/.pnpm')
const roots = [process.cwd(), ...(() => {
  try { return readdirSync(pnpm).filter((d) => /^playwright(-core)?@/.test(d)).map((d) => join(pnpm, d)) } catch { return [] }
})()]
let chromium
for (const root of roots) for (const name of ['playwright', 'playwright-core', '@playwright/test']) {
  if (chromium) break
  try { ({ chromium } = createRequire(join(root, 'noop.js'))(name)) } catch {}
}
if (!chromium) { console.error('shoot: no Playwright in this project (playwright, playwright-core or @playwright/test)'); process.exit(2) }
let audit
try {
  ;({ auditLayout: audit } = await import(pathToFileURL(join(o.stageshow, 'scripts/layout-core.mjs')).href))
} catch { console.error(`shoot: no stageshow at ${o.stageshow}; box-fit check off`) }

mkdirSync(o.out, { recursive: true })
const slug = (u) => new URL(u).pathname.replace(/^\/|\/$/g, '').replace(/[^\w-]+/g, '-') || 'root'
const browser = await chromium.launch()
process.on('SIGINT', () => void browser.close().then(() => process.exit(130)))
let failed = false
const report = []
try {
  for (const url of urls) for (const look of o.looks.split(',')) for (const w of o.widths.split(',').map(Number)) {
    const ctx = await browser.newContext({ viewport: { width: w, height: Number(o.height) }, colorScheme: look === 'dark' ? 'dark' : 'light' })
    const page = await ctx.newPage()
    const errors = []
    page.on('pageerror', (e) => errors.push(`page: ${e.message}`))
    page.on('console', (m) => m.type() === 'error' && !/^Failed to load resource/.test(m.text()) && errors.push(`console: ${m.text().slice(0, 200)}`))
    page.on('response', (r) => r.status() >= 400 && !/favicon/.test(r.url()) && errors.push(`http ${r.status()}: ${r.url().slice(0, 160)}`))
    let target = url
    const param = o[`${look}-param`], js = o[`${look}-js`]
    if (param) target += (url.includes('?') ? '&' : '?') + param
    await page.goto(target, { waitUntil: 'domcontentloaded' })
    await page.locator(o.select).first().waitFor({ state: 'visible', timeout: 15000 }).catch(() => errors.push(`no ${o.select}`))
    await page.evaluate(() => document.fonts.ready)
    await page.waitForTimeout(Number(o.wait))
    if (js) { await page.evaluate(js); await page.waitForTimeout(300) }
    // the ground's color stands for the look: two looks with one ground are one look
    const ground = await page.evaluate((sel) => {
      for (let el = document.querySelector(sel); el; el = el.parentElement) {
        const c = getComputedStyle(el).backgroundColor
        if (c && c !== 'rgba(0, 0, 0, 0)' && c !== 'transparent') return c
      }
      return getComputedStyle(document.documentElement).backgroundColor
    }, o.select)
    const path = join(o.out, `${slug(url)}-${look}-${w}.png`)
    await page.screenshot({ path, fullPage: o.full })
    const found = audit ? await page.locator(o.select).first().evaluate(audit).catch((e) => ({ findings: [], error: e.message })) : { findings: [] }
    failed ||= errors.length > 0
    report.push({ url, look, width: w, path, ground, errors, findings: found.findings?.map((f) => f.message) ?? [] })
    const c = found.checked ?? {}
    console.log(`${path}  ${found.findings?.length ?? 0} box-fit (of ${c.controls ?? 0} controls, ${c.paddedContainers ?? 0} boxes), ${errors.length} errors`)
    for (const f of found.findings ?? []) console.log(`  fit: ${f.message}`)
    for (const e of errors) console.log(`  err: ${e}`)
    await ctx.close()
  }
} finally {
  await browser.close()
}
// an app that sets its own look ignores prefers-color-scheme: say so, never pass two equal shots off as both looks
for (const r of report.filter((r) => r.look === 'dark')) {
  const twin = report.find((x) => x.look === 'light' && x.url === r.url && x.width === r.width)
  if (twin && twin.ground === r.ground) {
    failed = true
    console.log(`same look: light and dark share the ground ${r.ground} at ${r.width} (${r.url}). The app sets its own look; pass --light-js/--dark-js or --light-param/--dark-param.`)
  }
}
writeFileSync(join(o.out, 'report.json'), JSON.stringify(report, null, 2))
console.log(`report: ${join(o.out, 'report.json')}. Read every PNG; this is not approval.`)
process.exit(failed ? 1 : 0)
