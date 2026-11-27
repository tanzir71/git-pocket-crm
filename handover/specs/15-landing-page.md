# 15 Landing page

## Goal

A landing page for PocketCRM at `https://tanzir71.github.io/git-pocket-crm/`, served by GitHub Pages from the `docs/` folder on `main`, matching the design, with no build step, no JavaScript and no requests to any other site.

It is built in two parts. **Part A** (milestone M1) puts the page live in a "being built" state. **Part B** (milestone M5, after spec 14) switches it to a working download.

## Read first

`handover/design/landing/landing-desktop.png` and `landing-mobile.png` (the design at 1440 and 390 wide). Figma frames `14:586` and `14:856`. `handover/02-design-system.md` for the tokens. Look at the images before writing any markup, and again when comparing the result.

## Decisions

- **Plain HTML and CSS** in `docs/`. No framework, no generator, no bundler, no JavaScript.
- **Nothing is loaded from another origin.** No web fonts from a CDN, no analytics, no badges, no embeds. The page promises privacy, so it must not make a single third-party request. Links to GitHub are ordinary links.
- **Published from a branch**, with a `.nojekyll` file so GitHub serves the folder as it is and no GitHub Actions run is needed.
- **One typeface:** Inter, self-hosted as a variable `woff2` in `docs/assets/fonts/` with its licence file beside it. No italics.
- **Same tokens as the app,** as CSS custom properties, with the dark values under `prefers-color-scheme: dark`.
- **All paths are relative,** because the site lives under `/git-pocket-crm/`.

## Files

```
docs/.nojekyll
docs/index.html
docs/styles.css
docs/404.html                 same header and footer, one line, a link home
docs/favicon.svg              the letter P in white on accent/default, radius 22 percent
docs/og.png                   1200 by 630 social image
docs/assets/fonts/InterVariable.woff2, OFL.txt
docs/assets/screen-today.webp, .png
docs/assets/screen-after-call.webp, .png
docs/assets/screen-new-message.webp, .png
tool/check_landing.sh
```

## Layout

Content is at most 1120 wide and centred, with at least 24 of side padding. Below a viewport width of 1040 the layout switches to the single-column mobile design with 20 of side padding. Section padding top and bottom is 104 (56 on mobile). Sections alternate background as listed.

| Section | Background | Desktop | Mobile |
|---|---|---|---|
| Nav | `bg/canvas` | 72 high. Wordmark "PocketCRM" (16/22, weight 600) left. Right: links How it works, Messages, Privacy, Install (13/18, weight 500, `text/secondary`, 28 apart), then a small secondary button | 60 high. Wordmark and the small button only |
| Hero | `bg/canvas` | Padding 64 top, 104 bottom. Two columns, 80 apart, vertically centred. Copy column 580 wide. Phone 313 wide, centred in the rest | Padding 32 top, 56 bottom. Copy, then the phone (271 wide) centred 40 below. Buttons stacked |
| How it works | `bg/surface` | Phone (288 wide) left, steps right, 96 apart | Heading, steps, then the phone centred |
| Who it is for | `bg/canvas` | Heading, then two columns 80 apart | Columns stacked, 40 apart |
| Messages | `bg/surface` | Copy left, phone (288 wide) right, 96 apart | Copy, then the phone centred |
| Privacy | `bg/inverse` | Text block at most 820 wide, left aligned | Full width |
| Install | `bg/canvas` | Heading, three steps in a row 48 apart, a bordered note, then the button | Steps stacked |
| Footer | `bg/canvas`, 1 px top `border/hairline` | Padding 36. Brand left, links right | Stacked, padding 28 |

Type on the page:

| Role | Desktop | Mobile |
|---|---|---|
| h1 | 56/60, weight 600, letter spacing -1.4 | 36/42, -0.7 |
| h2 | 36/42, weight 600, -0.7 | 26/32, -0.4 |
| Lead | 19/30, weight 400 | 17/26 |
| h3 and row titles | 16/22, weight 600. Column headings in "Who it is for" are 20/26 | same |
| Body | 16/24, weight 400 (the Figma frames show the app's 15/22; use 16/24 on the web) | same |
| Label | 13/18, weight 500 | same |
| Caption | 12/16, weight 400 | same |

Details:

- **Phone.** Build the frame in CSS: a `bg/inverse` box with 8 of padding and a 40 radius, holding the screen image with a 32 radius. The files `handover/design/landing/phone-*.png` show the framed result. Give every image explicit `width` and `height`, real `alt` text, and `loading="lazy"` except the hero's.
- **List rows** (steps, audience lines, facts) have a 1 px top `border/hairline` and no other decoration. Step numbers are `text/tertiary`, 26/32 weight 600 in a 40 wide column on desktop, 20/26 in a 28 wide column on mobile.
- **Facts** in Messages: the key is 200 wide in weight 500, the value is `text/secondary`. On mobile the key sits above the value.
- **Privacy** text is `text/on-inverse`; the paragraph is at 78 percent opacity; the two links are weight 500 and underlined.
- **The note** in Install is `bg/surface` with a 1 px hairline border, radius 16, padding 24 by 28.
- **Buttons** follow the app's: primary 48 high, radius 12, `accent/default`; small secondary 36 high, radius 10, `bg/subtle`; quiet is text only in `text/secondary`. The accent appears once in the hero and once in Install, nowhere else.
- **Focus** is a visible 2 px `accent/default` outline with a 2 px offset. **Hover** darkens a button by 6 percent and underlines a text link. No other motion. Smooth scrolling for the nav links only when the visitor has not asked for reduced motion.

## Copy

Use these words exactly. Sentence case, no exclamation marks.

**Nav:** How it works · Messages · Privacy · Install

**Hero**
- Line above the heading: Android app · No account · Works offline
- h1, two lines: Remember every conversation. / Follow up on time.
- Lead: PocketCRM turns your phone's calls and messages into a history for each person. Add a note in seconds after a call or a visit, set the next step, and it comes back when it is due.
- Image: Today. Alt: "The Today screen: a prompt to note a call that just ended, three follow-ups, and two people to reconnect with."

**How it works** (h2: How it works)
1. It logs itself. Calls and SMS with the people you have saved appear in their history. You enter nothing.
2. Note it in seconds. When a call ends, PocketCRM asks how it went. Type or dictate a line. Visits, payments and files go in the same sheet.
3. Set the next step. Tomorrow, in three days, next week, or a date. One tap, on every entry.
4. It comes back on time. Today lists what is due, who you have not spoken to for too long, and what is going out.
- Image: After-call note. Alt: "The note sheet after a call, with the outcome, a note, and a follow-up set for tomorrow."

**Who it is for** (h2: For work, and for everyone else)
- If you sell from your phone: A note after every call and every visit · Follow-ups that remind you at the right time · Who owes you, and a reminder in two taps · One message to a whole list, with each name and amount filled in
- If you want to keep up with people: See when you last spoke to someone · Choose how often you want to be in touch · Remember what was said last time · Birthdays a week ahead

**Messages** (h2: Messages that send themselves, and tell you what happened)
- Lead: Schedule a message to one person, or a personalised one to a whole list. PocketCRM sends it from your phone at the time you chose and shows the result for every person.
- Your own number: Sent from your SIM, so replies come to you.
- Paced and pausable: One every few seconds, only in the hours you set.
- A result for each person: Sent, delivered, or not sent and why.
- Image: New message. Alt: "The message composer with a personalised reminder, a preview for one person, and the send time and pace."

**Privacy** (h2: It cannot connect to the internet)
- Paragraph: No account, no server, no analytics. The app does not hold Android's internet permission, so your calls, messages and notes have nowhere to go. Backups are files you keep, protected with a passphrase if you want one.
- Links: See the permission list · Read the source

**Install** (h2: Install in a minute)
1. Download the APK. Open it from your notifications or your Files app.
2. Allow the install. Android asks once to allow installs from your browser.
3. Finish setup. PocketCRM walks you through contacts, calls and messages, and the settings scheduled sending needs.
- Note heading: Why it is not on Google Play
- Note: Google Play only lets an app read call and message history if it replaces your phone or SMS app. PocketCRM works beside the ones you already use, so it is published here instead.

**Footer:** PocketCRM · A private relationship app for Android. · GitHub · Releases · Changelog

## The two states

The design images show the part B state.

| Element | Part A, while v2 is being built | Part B, after the 2.0.0 release |
|---|---|---|
| Nav button | "GitHub", to the repository | "GitHub" on desktop, "Download" on mobile |
| Hero primary button | "Follow the build on GitHub", to the repository | "Download for Android", to `https://github.com/tanzir71/git-pocket-crm/releases/latest/download/PocketCRM.apk` |
| Hero quiet button | "See milestone builds", to the releases page | "View source on GitHub" |
| Hero caption | "Version 2 is being built in the open. Each milestone is published as it lands." | "Installs from an APK file. Everything stays on your phone." |
| Install button and caption | "See milestone builds" · "Version 2.0 is not released yet." | "Download for Android" · "Android only. Every release is on GitHub." |
| "See the permission list" | `android/app/src/main/AndroidManifest.xml` on GitHub | `tool/allowed_permissions.txt` on GitHub |
| Screen images | Resized from `handover/design/screens/01-today.png`, `02-after-call-note.png`, `07-new-message.png` | Screenshots of the real app showing the same sample data, taken from the golden tests or an emulator |
| "Changelog" link | The file on GitHub (create `CHANGELOG.md` with an "In progress" heading if it does not exist) | The same |

The page must be true at every commit. It never says "open source", never shows user numbers, ratings, awards or quotes, and never claims the app works on every phone.

## Steps, part A

1. Create the files. Write semantic HTML: `header`, `nav`, `main` with one `section` per row of the layout table, `footer`; one `h1`; headings in order; a skip link; `lang="en"`.
2. Put the tokens in `:root` as custom properties named after the tokens (`--bg-canvas`, `--text-primary`, and so on), with the dark set under the media query. Style only with those.
3. Images: resize each screen to 626 wide (twice the largest display size), write WebP at quality 82 and a PNG fallback, and use `picture`. If no image tool is available, use the PNGs as they are.
4. Head: title "PocketCRM: remember every conversation, follow up on time"; a description of at most 155 characters taken from the lead; a canonical link; Open Graph and Twitter card tags pointing at the absolute address of `og.png`; `theme-color` for light and dark.
5. `og.png`: `bg/canvas`, the wordmark, the two-line heading in weight 600, and the Today screen in its frame on the right. Render it from a local HTML file under `tool/og/` with a headless browser if one is installed, or compose it with a short script. If neither is possible, leave the tag out and note it in `DECISIONS.md`.
6. `tool/check_landing.sh` fails if anything under `docs/` contains a `script` element, an `@import`, a `url(http`, or a `src` or stylesheet `href` that begins with `http` or `//`; if `index.html` has more than one `h1` or an `img` without `alt`, `width` and `height`; or if `.nojekyll` is missing. Add it to `tool/verify.sh`.
7. **Check it against the design.** Serve the repository root locally (`python -m http.server`) and open `/docs/`. Take full-page screenshots at 1440 and 390 wide with a headless browser and compare them, section by section, with the two design images. Fix differences in spacing, size, weight and colour. Also check 768 and 1040 wide, and dark mode. Save the screenshots in `handover/design/landing/built-*.png` and commit them.
8. Commit as `spec 15: landing page, part A` and push.
9. **Turn on GitHub Pages.**

```sh
echo '{"source":{"branch":"main","path":"/docs"}}' | gh api -X POST repos/tanzir71/git-pocket-crm/pages --input -
gh api repos/tanzir71/git-pocket-crm/pages --jq '.html_url, .status'
```

   If Pages already exists, use `-X PUT` with the same body. Then request `https://tanzir71.github.io/git-pocket-crm/` every 30 seconds for up to 10 minutes until it answers 200 and the body contains the h1. If the site does not appear and Actions were switched off in spec 00, switch them back on (`-F enabled=true`), push an empty commit, try again, and record what happened in `DECISIONS.md`. In that case GitHub's own Pages run is the only thing that runs there; still add no workflow file. The repository must be public for this step (spec 00).

## Steps, part B

1. After `tool/release.sh 2.0.0` has published the release, change the elements in the second column of the states table.
2. Replace the three screen images with screenshots of the real app, same sample data, light theme. Add dark versions and serve them with `picture` and `prefers-color-scheme`.
3. Read every sentence on the page against the app as built and against `handover/UNVERIFIED.md`. Change any sentence that is not true. If scheduled sending could not be shown on an emulator, change "at the time you chose" to "when its time comes".
4. Regenerate `og.png` with the real Today screenshot. Redo the design comparison. Commit as `spec 15: landing page, part B`, push, and confirm the live page serves the new button.

## Acceptance criteria

- `tool/check_landing.sh` passes.
- Loading the page with a headless browser and listing its network requests shows only requests to its own origin.
- The built screenshots at 1440 and 390 match the design images in layout, type sizes and colours; the differences you could not remove are listed in `DECISIONS.md`.
- At 320 wide nothing overflows horizontally. With the system font size at 200 percent nothing is cut off.
- The first load (HTML, CSS, font, hero image) is under 400 KB.
- Part A: the live address answers 200 and no link on the page leads to a 404.
- Part B: the hero button's address ends in a 200 and delivers a file whose SHA-256 matches the one in the release.

## Verify

```sh
tool/check_landing.sh && tool/verify.sh
curl -sI https://tanzir71.github.io/git-pocket-crm/ | head -1
```
