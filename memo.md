## vueのいろいろなレンダリング方法

- いつもの<script>, <template> <style>のやつから、optionsAPI形式、renderとhオプションなどいろいろあるので、まずはrenderとhオプションを目指す
- h関数でのレンダリングを選択する理由は最もjsに近く、実装が簡単だから。
https://book.chibivue.land/ja/10-minimum-example/010-create-app-api.html


## runtime-coreとruntime-dom登場

runtime-domはDOMに依存した処理
1. runtime-core/renderからruntime-dom/nodeOpsを呼び出す。あくまでruntime-core/renderの方は、renderのfactory関数の生成だけ。
2. runtime-dom/index.tsでは、runtime-coreで生成されたfactory関数を呼び出し、runtime-dom/nodeOpsも呼び出してDOM操作。

結論、繰り返すがruntime-core/renderはfactory関数の呼び出しだけ行って、実態はruntime-domでやっている


