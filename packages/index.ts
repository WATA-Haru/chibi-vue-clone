/**
 * Options型は、renderを持っていて、stringを返す関数をプロパティに持つ
 */
export type Options = {
  render: () => string
}

/**
 * mountしたときに、App型はmountを持っていて、それがstringを受け取っている
 * 何に使うんだろ
 */
export type App = {
  mount: (selector: string) => void
}

/**
 * selectorを受け取って、root.innerHTMLを直接options.renderで上書きしている感じ
 *
 * @example
*   - optionsには
*   ```
*   render: render() { return "hell word" }
*   ```
*   renderは省略できるけどこんな感じでわたってくる。
*   ```
*   const app =createApp({render() {return "hell word"}},}))
*   app.mount('#app')
*   ```
*   みたいにすると#appを作った後にroot.innerHTMLにtextをセットしてくれる感じか
 */
export const createApp = (options: Options):App => {
  return {
    mount: selector => {
      const root = document.querySelector(selector)
      if (root) {
        root.innerHTML = options.render()
      }
    }
  }
}

