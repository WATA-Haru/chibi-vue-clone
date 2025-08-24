/**
 * RenderOptionsはHostNodeに対する操作についてまとめている型っぽい
 * HostNodeにsetElementTextをしている。他のやつも出るだろう
 */
export interface RendererOptions<HostNode = RendererNode> {
  setElementText(node: HostNode, text: string):void
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
  const { setElementText: hostSetElementText } = options

  // RootRenderFunctionは、stringと、HostElementを受け取ってsetElementTextを実行
  const render: RootRenderFunction = (message, container) => {
    hostSetElementText(container, message) // いったんmessageの設定だけ
  }

  return { render }
}
