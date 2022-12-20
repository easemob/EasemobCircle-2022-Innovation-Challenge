import { createRoot } from "react-dom/client"
import { Provider } from "react-redux";
import store from '../../store'
import Plugin from './plugin'

export const iframeMap = new Map()
export const iframeDOMMap = new WeakMap()

const App = (plugin) => {
    return (
        <Provider store={store}>
            <Plugin url={plugin.url} setting={plugin.setting} name={plugin.name} />
        </Provider>
    )
}

/**
 * 
 * @param {object} plugin 
 * @param {string} plugin.url
 * @param {string} plugin.setting
 * @param {string} plugin.name
 */
export const openPlugin = (plugin) => {
    const originIframe = iframeMap.get(plugin.url)
    if (originIframe) {
        originIframe.focus()
        return
    }

    /**
     * @type {HTMLDivElement}
     */
    const rootDOM = document.createElement('div')
    const body = document.querySelector('body')
    body.appendChild(rootDOM)
    const root = createRoot(rootDOM)
    root.render(<App url={plugin.url} setting={plugin.setting} name={plugin.name} />)
    iframeMap.set(plugin.url, rootDOM)
    iframeDOMMap.set(rootDOM, root)
}