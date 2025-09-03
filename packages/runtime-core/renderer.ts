import { VNode, VNodeProps } from "./vnode"
/**
 * RenderOptionsはHostNodeに対する操作についてまとめている型っぽい
 * HostNodeにsetElementTextをしている。他のやつも出るだろう
 */
export interface RendererOptions<HostNode = RendererNode> {
  createElement(type: string): HostNode

  createText(type: string): HostNode

  setElementText(node: HostNode, text: string):void

  insert(child: HostNode, parent: HostNode, anchor?: HostNode | null): void
}

/** DOMに依存しないためのinterface*/
export interface RendererNode {
  [key: string]: any
}
/** DOMに依存しないためのinterface*/
export interface RendererElement extends RendererNode {}

export type RootRenderFunction<HostElement = RendererElement> = (
  message: string,
  container: HostElement,
) => void

export function createRenderer(options: RendererOptions) {
  const { 
    createElement: hostCreateElement,
    createText: hostCreateText,
    insert: hostInsert
  } = options

  function renderVNode(vnode: VNode | string) {
    if (typeof vnode === 'string') return hostCreateText(vnode)
    const el = hostCreateElement(vnode.type)

    for (const child of vnode.children) {
      const childEl = renderVNode(child)
      hostInsert(childEl, el)
    }

    return el
  }

  // RootRenderFunctionは、stringと、HostElementを受け取ってsetElementTextを実行
  const render: RootRenderFunction = (vnode, container) => {
    const el = renderVNode(vnode)
    hostInsert(el, container)
  }

  return { render }
}
