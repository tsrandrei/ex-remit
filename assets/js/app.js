// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}

// Fixes two issues:
// - Clicking a link with a phx-click did not cause the link default (navigation) to trigger.
// - Clicking a button inside the link *would* cause the link default to trigger.
Hooks.AllowLinkDefaultAndPreventNestedDefault = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      // `closest` in case we click an element inside a button, e.g. an icon.
      if (e.target.closest("button")) {
        e.preventDefault()
      } else {
        location.href = this.el.href
      }
    })
  }
}

Hooks.SetSession = {
  DEBOUNCE_MS: 200,

  mounted() {
    this.el.addEventListener("input", (e) => {
      clearTimeout(this.timeout)
      this.timeout = setTimeout(() => {
        this.pushEventTo(".phx-hook-subscribe-to-session", "set_session", [e.target.name, e.target.value])
        fetch(`/api/session?${e.target.name}=${encodeURIComponent(e.target.value)}`, { method: "post" })
      }, this.DEBOUNCE_MS)
    })
  },
 }

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
let progressTimeout = null
window.addEventListener("phx:page-loading-start", () => { clearTimeout(progressTimeout); progressTimeout = setTimeout(NProgress.start, 100) })
window.addEventListener("phx:page-loading-stop", () => { clearTimeout(progressTimeout); NProgress.done() })

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
