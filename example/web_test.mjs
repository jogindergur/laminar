import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  
  page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
  
  await page.goto('http://localhost:8080', { waitUntil: 'networkidle2' });
  
  console.log("Page loaded. Waiting a bit for Flutter to initialize...");
  await new Promise(r => setTimeout(r, 5000));
  
  console.log("Clicking somewhere to interact, or finding export button...");
  // But wait, what if I don't know the selector?
  // We can just evaluate dart code or look for semantics!
  // Alternatively I can just look at what export_mp4_web.dart is doing in the example screen and trigger it.
  await page.evaluate(() => {
     // I don't know the DOM, Flutter web renders to canvas.
  });

  await browser.close();
})();
