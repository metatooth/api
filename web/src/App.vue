<template>
  <div
    id="app"
    class="container"
  >
    <main-nav
      :token="access_token"
      :on-settings="do_settings"
      :on-signout="do_signout"
    />
    <sign-up
      v-if="signup_visible"
      :on-close="show_signin"
    />
    <sign-in
      v-if="signin_visible"
      :on-signin="do_signin"
      :on-signup="show_signup"
    />
    <meals
      v-if="meals_visible"
      :meals="meals"
      :expected-daily-calories="active_user.expected_daily_calories"
      :token="access_token"
      :on-edit="show_editor"
    />
    <editor
      v-if="editor_visible"
      :record="active_meal"
      :cache="cache_meal"
      :token="access_token"
      :on-close="show_meals"
    />
    <settings
      v-if="settings_visible"
      :record="active_user"
      :cache="cache_user"
      :token="access_token"
      :on-close="show_meals"
    />
  </div>
</template>

<script>
import MealsService from './api-services/meals'
import UsersService from './api-services/users'

import Editor from './components/Editor.vue'
import MainNav from './components/MainNav.vue'
import Settings from './components/Settings.vue'
import SignUp from './components/SignUp.vue'
import SignIn from './components/SignIn.vue'
import Meals from './components/Meals.vue'

export default {
  name: 'App',
  components: {
    Editor,
    MainNav,
    Meals,
    Settings,
    SignUp,
    SignIn
  },
  data () {
    return {
      access_token: '',
      active_meal: null,
      active_user: null,
      cache_meal: null,
      cache_user: null,
      editor_visible: false,
      meals: [],
      settings_visible: false,
      signin_visible: true,
      signup_visible: false,
      meals_visible: false,
      users: []
    }
  },
  methods: {
    do_cancel_signup: function () {
      this.show_signin()
    },
    do_settings: function () {
      this.show_settings()
    },
    do_signin: function(token) {
      this.access_token = token
      
      MealsService.get_all(this.access_token)
        .then(response => {
          this.meals = response.data
        }).catch(error => {
          console.log(error)
        })

      UsersService.get_all(this.access_token).then(response => {
        console.log(response.data[0])
        if (response.data.length == 1) {
          // :TRICKY: 20190604 Terry: This single entry _should_ match the authenticated user. 
          this.active_user = response.data[0]
        } else {
          for (let i = 0; i < response.data.length; ++i) {
            if (response.data[i].access_token == this.access_token) {
              this.active_user = response.data[i]
            }
          }
        }
        this.show_meals()
      }).catch(error => {
        console.log(error)
      })
    },
    do_signout: function() {
      this.access_token = ''
      this.show_signin()
    },
    show_editor: function (meal) {
      this.active_meal = meal
      
      this.cache_meal = {}
      this.cache_meal['id'] = meal['id']
      this.cache_meal['taken'] = meal['taken']
      this.cache_meal['text'] = meal['text']
      this.cache_meal['calories'] = meal['calories']

      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = false
      this.editor_visible = true
    },
    show_settings: function () {
      this.cache_user = {}
      this.cache_user['expected_daily_calories'] = this.active_user['expected_daily_calories']

      this.settings_visible = true
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = false
      this.editor_visible = false
    },
    show_signin: function () {
      this.settings_visible = false
      this.signin_visible = true
      this.signup_visible = false
      this.meals_visible = false
      this.editor_visible = false
    },
    show_signup: function () {
      this.signin_visible = false
      this.settings_visible = false
      this.signup_visible = true
      this.meals_visible = false
      this.editor_visible = false
    },
    show_meals: function () {
      this.active_meal = null
      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = true
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
