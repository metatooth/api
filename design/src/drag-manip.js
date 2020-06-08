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

import {Manipulator} from './manipulator';

/**
 * Description: Mousedown. Drag... Mouseup.
 * @param {Viewer} viewer - for visualization
 * @param {Rubberband} rubberband - used to track mouse movement
 */
function DragManip( viewer, rubberband ) {
  Manipulator.call( this );

  this.type = 'DragManip';

  this.viewer = viewer;
  this.rubberband = rubberband;
}

DragManip.prototype = Object.assign( Object.create( Manipulator.prototype ), {
  constructor: DragManip,

  isDragManip: true,

  /**
   * @param {Event} event - the mousedown event to start the drag
   */
  grasp: function( event ) {
    this.grasp = event;

    const x = ( event.clientX / window.innerWidth ) * 2 - 1;
    const y = - ( event.clientY / window.innerHeight ) * 2 + 1;
    this.rubberband.track( x, y );
  },

  /**
   * @param {Event} event - is dragging
   * @return {boolean}
   */
  manipulating: function( event ) {
    if ( event.shiftKey && event.type == 'mousemove' ) {
      const x = ( event.clientX / window.innerWidth ) * 2 - 1;
      const y = - ( event.clientY / window.innerHeight ) * 2 + 1;
      this.rubberband.track( x, y );
    } else if ( !event.shiftKey || event.type == 'mouseup' ) {
      return false;
    }
    return true;
  },

  /**
   * @param {Event} event - mouseup to end the drag
   */
  effect: function( event ) {
  },
});

export {DragManip};