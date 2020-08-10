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

import {Vector3} from 'three';

import {Manipulator} from './manipulator';

/**
 * Description: Mousedown. Drag... Mouseup.
 * @param {Viewer} viewer - for visualization
 * @param {Rubberband} rubberband - used to track mouse movement
 * @param {Tool} tool - for user interaction
 */
function DragManip( viewer, rubberband, tool ) {
  Manipulator.call( this );

  this.type = 'DragManip';

  this.viewer = viewer;
  this.rubberband = rubberband;
  this.tool = tool;

  this.label = null;
  this.mouse = new Vector3;
  this.dimension = 25;
}

DragManip.prototype = Object.assign( Object.create( Manipulator.prototype ), {
  constructor: DragManip,

  isDragManip: true,

  /**
   * Track the mouse location in world coordinates with the rubberband.
   * @param {Event} event - use the client X & Y
   */
  unproject: function( event ) {
    this.mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1;
    this.mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;
    this.mouse.z = -1;

    this.mouse.unproject( this.viewer.camera );

    this.rubberband.track( this.mouse );

    if (!this.label) {
      this.label = document.createElement('div');
      this.label.style.pointerEvents = 'none';
      this.label.style.position = 'absolute';
      this.label.style.margin = '0px';
      this.label.style.backgroundColor = '#fdfdfd';
      this.label.style.padding = '0px 5px 0px';
      this.label.style.borderStyle = 'dotted';
      this.label.style.borderWidth = '3px';
      this.label.style.borderColor = '#ff7700';

      document.body.appendChild(this.label);
    }

    const curr = this.rubberband.current();

    this.label.innerHTML = curr[0].distanceTo(curr[1]).toFixed(1);

    const mid = this.rubberband.midpoint(curr[0], curr[1]);

    mid.unproject( this.viewer.camera );

    const x = window.innerWidth*((mid.x+1)/2) - (this.label.offsetWidth/2.);
    const y = window.innerHeight*((-mid.y+1)/2) + (this.label.offsetHeight/2.);

    this.label.style.top = y + 'px';
    this.label.style.left = x + 'px';
  },

  /**
   * @param {Event} event - the mousedown event to start the drag
   */
  grasp: function( event ) {
    this.viewer.controls.enabled = false;
    this.viewer.controls.saveState();

    const p = this.viewer.unproject( event.clientX, event.clientY );
    this.rubberband.track( p );
    console.log('grasp p', p.x, p.y, p.z);

    this.viewer.scene.add(this.rubberband);
  },

  /**
   * @param {Event} event - is dragging
   * @return {boolean}
   */
  manipulating: function( event ) {
    if ( event.type == 'mousemove' ) {
      const p = this.viewer.unproject( event.clientX, event.clientY );
      console.log('manipulating p', p.x, p.y, p.z);
      this.rubberband.track( p );
    } else if (event.type == 'mouseup' ) {
      return false;
    }
    return true;
  },

  /**
   * @param {Event} event - mouseup to end the drag
   */
  effect: function( event ) {
    this.viewer.scene.remove(this.rubberband);

    this.viewer.controls.reset();
    this.viewer.controls.enabled = true;
  },
});

export {DragManip};
