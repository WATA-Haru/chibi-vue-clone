現在のコード構造を理解した上で、DIP（依存関係逆転の原則）とDI（依存性注入）の実装について解説します。

## DIP + DI アーキテクチャの全体像

### 1. 依存関係の構造

```
高レベル → 低レベル （通常の依存関係）
createAppAPI → DOM操作

DIP適用後：
高レベル ← 低レベル （依存関係逆転）
createAppAPI ← render関数（抽象） ← DOM操作
```

### 2. 各層の役割

**① createAppAPI（高レベルモジュール・ファクトリ関数）**
```typescript
// packages/runtime-core/apiCreateApp.ts
export function createAppAPI<HostElement>(
  render: RootRenderFunction<HostElement>, // 抽象的な依存性
): CreateAppFunction<HostElement> {
  return function createApp(rootComponent) {
    const app: App = {
      mount(rootContainer: HostElement) {
        const message = rootComponent.render!()
        render(message, rootContainer) // 注入された実装を使用
      },
    }
    return app
  }
}
```

**役割：**
- アプリケーションの**ライフサイクル管理ロジック**
- `render`関数という**抽象**に依存（具体的なDOM操作は知らない）
- プラットフォーム非依存

**② createRenderer（依存性注入の実行者）**
```typescript
// packages/runtime-core/renderer.ts
export function createRenderer<HostElement>(
  options: RendererOptions<HostElement>, // DOM操作の具体実装
) {
  const render: RootRenderFunction<HostElement> = (message, container) => {
    // DOM操作の具体実装を使用
    const el = createElement('div')
    setElementText(el, message)
    insert(el, container)
  }

  return {
    render,
    createApp: createAppAPI(render), // 依存性注入
  }
}
```

**役割：**
- プラットフォーム固有の操作を受け取り、`render`関数を構築
- `render`関数を`createAppAPI`に**注入**
- 抽象と具体実装の**橋渡し**

**③ runtime-dom（具体実装の提供）**
```typescript
// packages/runtime-dom/index.ts
const { render, createApp } = createRenderer({
  patchProp,
  ...nodeOps, // DOM操作の具体実装
})
```

**役割：**
- **DOM操作の具体実装**を提供
- ユーザーが実際に使用する`createApp`関数を生成

### 3. 依存性注入の流れ

```
1. runtime-dom: DOM操作の具体実装を準備
   ↓ (DI)
2. createRenderer: 具体実装を受け取り、render関数を作成
   ↓ (DI)
3. createAppAPI: render関数を受け取り、createApp関数を生成
   ↓ (結果)
4. ユーザー: DOM操作の詳細を知らずにcreateAppを使用
```

### 4. DIPのメリット

**従来の設計（DIP未適用）:**
```typescript
// createAppがDOM操作に直接依存
function createApp(rootComponent) {
  return {
    mount(container) {
      const el = document.createElement('div') // DOM に直接依存
      el.textContent = rootComponent.render()
      container.appendChild(el)
    }
  }
}
```

**DIP適用後:**
```typescript
// createAppは抽象的なrender関数に依存
function createAppAPI(render) { // 抽象に依存
  return function createApp(rootComponent) {
    return {
      mount(container) {
        render(rootComponent.render(), container) // 具体実装を知らない
      }
    }
  }
}
```

### 5. 実際の使用例

```typescript
// ユーザーコード
import { createApp } from '@vue/runtime-dom'

const app = createApp({
  render() {
    return 'Hello Vue!'
  }
})
app.mount('#app')

// 内部的な流れ：
// 1. DOM操作 → createRenderer → render関数生成
// 2. render関数 → createAppAPI → createApp関数生成  
// 3. createApp関数でアプリケーション作成
// 4. mount()でDOM操作実行（注入されたrender関数経由）
```

この設計により、**同じアプリケーションロジック**で異なるプラットフォーム（SSR、WebGL等）に対応でき、テストも容易になります。
