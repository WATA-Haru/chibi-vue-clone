import { createApp, h } from "chibivue"

const app = createApp({
  render() {
    return h('div', {}, [
      h('p', {}, ['Hello ChibiVue!']),
      h('button', {}, ['click me']),
      h('input', {}, []),
    ])
  },
})

app.mount('#app')

