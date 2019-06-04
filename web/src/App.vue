<template>
  <div id="app" class="container">
    <main-nav :token="access_token" :on-signout="do_signout"></main-nav>
    <sign-up v-if="signup_visible" :on-close="show_signin"></sign-up>
    <sign-in v-if="signin_visible" :on-signin="do_signin" :on-signup="show_signup"></sign-in>
    <tracker v-if="tracker_visible" :meals="meals" :token="access_token" :on-edit="show_editor"></tracker>
    <editor v-if="editor_visible" :meal="active_meal" :token="access_token" :on-close="show_tracker"></editor>
  </div>
</template>

<script>
import MealsService from './api-services/meals'

import Editor from './components/Editor.vue'
import MainNav from './components/MainNav.vue'
import SignUp from './components/SignUp.vue'
import SignIn from './components/SignIn.vue'
import Tracker from './components/Tracker.vue'

export default {
  components: {
    Editor,
    MainNav,
    SignUp,
    SignIn,
    Tracker
  },
  name: 'app',
  data () {
    return {
      access_token: '',
      active_meal: null,
      editor_visible: false,
      meals: [],
      signin_visible: true,
      signup_visible: false,
      tracker_visible: false,
      users: []
    }
  },
  methods: {
    do_cancel_signup: function () {
      this.show_signin()
    },
    do_signin: function(token) {
      this.access_token = token
      MealsService.get_all(this.access_token).then(response => {
        this.meals = response.data
        this.show_tracker()
      }).catch(error => {
        console.log(error)
      })
    },
    do_signout: function() {
      this.access_token = ''
    },
    show_editor: function (meal) {
      this.active_meal = meal
      this.signin_visible = false
      this.signup_visible = false
      this.tracker_visible = false
      this.editor_visible = true
    },
    show_signin: function () {
      this.signin_visible = true
      this.signup_visible = false
      this.tracker_visible = false
      this.editor_visible = false
    },
    show_signup: function () {
      this.signin_visible = false
      this.signup_visible = true
      this.tracker_visible = false
      this.editor_visible = false
    },
    show_tracker: function () {
      this.active_meal = null
      this.signin_visible = false
      this.signup_visible = false
      this.tracker_visible = true
      this.editor_visible = false
    }
  }
}
</script>

<style lang="scss">
@charset "utf-8";
@import "~bulma/bulma";

[v-cloak] { display: none; }

</style>
