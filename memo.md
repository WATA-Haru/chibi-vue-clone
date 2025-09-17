## vueのいろいろなレンダリング方法

- いつもの<script>, <template> <style>のやつから、optionsAPI形式、renderとhオプションなどいろいろあるので、まずはrenderとhオプションを目指す
- h関数でのレンダリングを選択する理由は最もjsに近く、実装が簡単だから。
https://book.chibivue.land/ja/10-minimum-example/010-create-app-api.html


## runtime-coreとruntime-dom登場

runtime-coreが、Vue.jsのコアの機能部分
runtime-domが、DOM操作に関連する。

具体的には、`runtime-core/renderer.ts`, `runtime-dom/nodeOps.ts`について。今までは、createAppで直接DOM操作をしていたが、リファクタリングする際には分離する必要がある。
```
```ts
// これは先ほどのコード
export const createApp = (options: Options): App => {
  return {

    mount: selector => {
      const root = document.querySelector(selector)
      if (root) {
        root.innerHTML = options.render() // レンダリング
      }
    },
  }
}
```


`runtime-dom/nodeOps.ts` -> DOM操作をするためのオブジェクトを入れる
`runtime-core/renderer.ts` -> renderの**ロジックのみ**を持つファクトリ関数を実装する。そして、Nodeを扱うオブジェクトはfactory関数の引数として受け取る
`runtime-dom/index.ts` -> nodeOpsとrendererのファクトリを基にrendererを完成させる。

つまり、nodeOpsが実際のDOM操作の担当、runtime-coreのrendererがレンダリングのロジックを提供
rendererとnodeOpsを組み合わせてruntime-dom/index.tsで実際にレンダリングしていくってことか。


factory関数とは
- オブジェクトやインスタンス生成の関数のことで、コンストラクタやクラスを使わなくてよい、便利
- ここで`runtime-core/renderer.ts`は何らかの規則に基づくインスタンスを生成するっていうことか。

実際に、`runtime-dom/nodeOps.ts`と`runtime-core/renderer.ts`を見ていくと、これらの実装とfactory関数の型が一致していることが分かる。そして、`runtime-dom/index.ts`はrenderer.tsの関数の中にnodeOpsを渡すだけで動く。

## DIPを利用したDI
DIP: Dependency Inversion Principle
- 高水準のモジュールは低水準のモジュールに依存

> 注目するべきところは，renderer.ts に実装した RendererOptions という interface です．
> ファクトリ関数も，nodeOps もこの RendererOptions を守るように実装します．(RendererOptions というインタフェースに依存させる)
> https://book.chibivue.land/ja/10-minimum-example/015-package-architecture.html#di-%E3%81%A8-dip



## h関数でレンダリングできるようにする
https://book.chibivue.land/ja/10-minimum-example/020-simple-h-function.html

だんだん分かってきたかも
h関数は以下のようなインターフェースにして、戻り値はresultのオブジェクト型とする。
```ts
const result = h('div', { class: 'container' }, ['hello'])
```

```ts
const result = {
  type: 'div',
  props: { class: 'container' },
  children: ['hello'],
}
```

render関数からresultのようなオブジェクトを受け取って、これをもとにDOM操作してrenderingする。
render関数はsetHTMLElementとかcreateTextNodeとかの関数だと思えばよい
```ts
const app: App = {
  mount(rootContainer: HostElement) {
    const node = rootComponent.render!()
    render(node, rootContainer)
  }
}
```
なお、nodeというオブジェクトに変わったものは仮想DOMと呼ばれる。






