/*
 * Copyright (c) 1990, 1991 Stanford University
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of Stanford not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  Stanford makes no representations about
 * the suitability of this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 *
 * STANFORD DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
 * IN NO EVENT SHALL STANFORD BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
 * WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

import {Command} from '../commands/command.js';
import {VertexManip} from '../vertex-manip.js';
import {Rubberband} from '../rubberband.js';
import {Tool} from './tool.js';
import {Vector2, Raycaster} from 'three';

/**
 * Description: A tool for drawing.
 * @constructor
 */
function MarkTool() {
  Tool.call( this );

  this.type = 'MarkTool';
}

MarkTool.prototype = Object.assign( Object.create( Tool.prototype ), {
  constructor: MarkTool,

  isMarkTool: true,

  /**
   * @param {Viewer} viewer - the container
   * @param {Event} event - the starting event
   * @return {Manipulator}
   */
  create: function( viewer, event ) {
    let manipulator = null;

    const mouse = new Vector2;
    mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1;
    mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;

    const raycaster = new Raycaster;
    raycaster.setFromCamera( mouse, viewer.camera );
    const intersects = raycaster.intersectObject( viewer.mesh() );

    if ( intersects.length > 0 ) {
      const rubberband = new Rubberband( mouse.x, mouse.y );
      manipulator = new VertexManip( viewer, rubberband );
    }

    return manipulator;
  },

  /**
   * @param {Manipulator} manipulator - the manipulation to analyze
   * @return {Command}
   */
  interpret: function( manipulator ) {
    return new Command;
  },
});

export {MarkTool};