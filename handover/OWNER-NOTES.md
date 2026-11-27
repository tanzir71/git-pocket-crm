# Notes for the owner

Nothing in this project waits for you. The agent commits to `main`, pushes, tests on its own, and publishes each milestone. These notes are for your information only.

| Topic | What to know |
|---|---|
| Signing key | The agent creates the release keystore in `.pocketcrm` inside your user folder (`%USERPROFILE%\.pocketcrm` on Windows, `~/.pocketcrm` elsewhere), outside the repository, in spec 01. Every release is signed with it. If that folder is lost, a new build cannot update an installed copy of the app; the app would have to be reinstalled and restored from a backup. Copying the folder somewhere safe once is enough |
| Licence | The repository has no licence file. Public without a licence means anyone can read the code but nobody has the right to reuse it. The agent will not add one and will not call the project open source. Adding a `LICENSE` file later is all it takes if you want that |
| What is not proven | The agent tests with automated tests and Android emulators. It cannot show how a real mobile network, a dual-SIM phone, the "Allow restricted settings" step, or a phone maker's battery manager behave. `handover/UNVERIFIED.md` lists these plainly. If something misbehaves on your phone, that file says where to look first |
| Developer verification | Google has said that installing apps from outside Play will need a verified developer as its programme rolls out worldwide from January 2027. Registration is tied to your identity, so the agent cannot do it. Nothing in this plan depends on it today. https://developer.android.com/developer-verification/guides |
| Figma | The design is in your Pocket-CRM file: nine app screens, the landing page at two widths, 49 components and the tokens. The markdown and the images in `handover/design/` are what the agent builds from, so a change in Figma only takes effect if the markdown is changed too |
| GitHub settings the agent changes | Repository visibility to public, description and homepage, GitHub Pages from `main` `/docs`, and GitHub Actions switched off. All are listed in spec 00 and spec 15. If the GitHub CLI on this machine is not signed in, spec 00 tells the agent to use the GitHub credential that git already stores for pushing, without printing or saving it |

The application id stays `com.pocketcrm.pocket_crm`. Changing it would make Android see a new app and leave existing data behind.
