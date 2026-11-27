/**
 * 2x photo of one visual straight from Power BI Desktop over its WebView2 CDP port (pbi-live -Abrir prints it).
 *   node tools/shot-visual.cjs <playwright-core dir> http://127.0.0.1:<cdp> "<text in the visual title>" preview.png 2
 * Maps the visual's box through every iframe (Desktop zooms the canvas), then Page.captureScreenshot with clip.scale.
 */
const { chromium } = require(process.argv[2]);
async function absBox(fr, r) {
  // Walk up the frame chain, mapping the rect into each parent's coordinates (handles CSS scale).
  while (fr.parentFrame()) {
    const fe = await fr.frameElement();
    const fb = await fe.boundingBox();
    const iw = await fr.evaluate(() => innerWidth);
    const k = fb.width / iw;
    r = { x: fb.x + r.x * k, y: fb.y + r.y * k, width: r.width * k, height: r.height * k };
    fr = fr.parentFrame();
  }
  return r;
}
(async () => {
  const [cdp, text, out, scale] = process.argv.slice(3);
  const b = await chromium.connectOverCDP(cdp);
  for (const ctx of b.contexts()) for (const pg of ctx.pages()) for (const fr of pg.frames()) {
    const el = await fr.$(`xpath=//*[contains(text(), ${JSON.stringify(text)})]/..`).catch(() => null);
    if (!el) continue;
    const r0 = await el.evaluate(e => { const b = e.getBoundingClientRect(); return { x: b.x, y: b.y, width: b.width, height: b.height }; });
    if (r0.width < 100) continue;
    const box = await absBox(fr, r0);
    const s = await ctx.newCDPSession(pg);
    const { data } = await s.send('Page.captureScreenshot', { format: 'png', clip: { ...box, scale: Number(scale) } });
    require('fs').writeFileSync(out, Buffer.from(data, 'base64'));
    console.log('ok', Math.round(box.width * scale), 'x', Math.round(box.height * scale));
    process.exit(0);
  }
  console.log('not found'); process.exit(1);
})();

