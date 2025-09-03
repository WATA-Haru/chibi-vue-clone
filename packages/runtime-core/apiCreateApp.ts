//mount(rootContainer: HostElement) {
//  const vnode = rootComponent.render!();
//  console.log(vnode); // ログを見てみる
//  render(vnode, rootContainer);
//},

import { Component } from './component'
import { RootRenderFunction } from './renderer'

export interface App<HostElement = any>
