import Vue from 'vue'
import App from './App.vue'

Date.prototype.yyyymmdd = function() {
  const mm = this.getMonth() + 1 // getMonth() is zero-based
  const dd = this.getDate()

  return [this.getFullYear(),
          (mm>9 ? '' : '0') + mm,
          (dd>9 ? '' : '0') + dd
         ].join('-')
}

Date.prototype.hhmm = function() {
  const hh = this.getHours()
  const mm = this.getMinutes();

  return [(hh>9 ? '' : '0') + hh,
          (mm>9 ? '' : '0') + mm
         ].join(':');
}

new Vue({
  el: '#app',
  render: h => h(App)
})
