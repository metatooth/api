<template>
  <div
    id="app"
    class="container"
  >
    <main-nav
      :active-user="active_user"
      :token="access_token"
      :on-settings="do_settings"
      :on-signout="do_signout"
      :on-users="show_users"
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
      :expected-daily-calories="parseInt(active_user.preferred_working_seconds_per_day)"
      :token="access_token"
      :on-edit="show_editmeal"
    />
    <edit-meal
      v-if="editmeal_visible"
      :record="edit_meal"
      :cache="cache_meal"
      :token="access_token"
      :on-close="show_meals"
    />
    <users
      v-if="users_visible"
      :users="users"
      :token="access_token"
      :on-edit="show_edituser"
    />
    <edit-user
      v-if="edituser_visible"
      :record="edit_user"
      :cache="cache_user"
      :token="access_token"
      :on-close="show_users"
    />
    <settings
      v-if="settings_visible"
      :record="active_user"
      :cache="cache_user"
      :token="access_token"
      :on-close="show_meals"
    />
    <footer class="footer">
      Questions to <a href="mailto:tgl@rideside.net">tgl@rideside.net</a>
    </footer>
  </div>
</template>

<script>
import MealsService from './api-services/meals'
import UsersService from './api-services/users'

import EditMeal from './components/EditMeal.vue'
import EditUser from './components/EditUser.vue'
import MainNav from './components/MainNav.vue'
import Meals from './components/Meals.vue'
import Settings from './components/Settings.vue'
import SignUp from './components/SignUp.vue'
import SignIn from './components/SignIn.vue'
import Users from './components/Users.vue'

export default {
  name: 'App',
  components: {
    EditMeal,
    EditUser,
    MainNav,
    Meals,
    Settings,
    SignUp,
    SignIn,
    Users
  },
  data () {
    return {
      access_token: '',
      active_user: null,
      cache_meal: null,
      cache_user: null,
      edit_meal: null,
      edit_user: null,
      editmeal_visible: false,
      edituser_visible: false,
      meals: [],
      settings_visible: false,
      signin_visible: true,
      signup_visible: false,
      meals_visible: false,
      users: [],
      users_visible: false
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
        if (response.data.length == 1) {
          this.users = []
          // :TRICKY: 20190604 Terry: This single entry _should_ match the authenticated user. 
          this.active_user = response.data[0]
        } else {
          this.users = response.data
          for (let i = 0; i < response.data.length; ++i) {
            // :NOTE: 20190605 Terry: This is why the access token is exposed in the users API response.
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
    show_editmeal: function (meal) {
      this.edit_meal = meal
      
      this.cache_meal = {}
      this.cache_meal['id'] = meal['id']
      this.cache_meal['taken'] = meal['taken']
      this.cache_meal['text'] = meal['text']
      this.cache_meal['calories'] = meal['calories']

      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = false
      this.editmeal_visible = true
      this.users_visible = false
      this.edituser_visible = false
    },
    show_edituser: function (user) {
      this.edit_user = user
      
      this.cache_user = {}
      this.cache_user['id'] = user['id']
      this.cache_user['username'] = user['username']
      this.cache_user['preferred_working_seconds_per_day'] = user['username']
      this.cache_user['type'] = user['type']

      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = false
      this.editmeal_visible = false
      this.users_visible = false
      this.edituser_visible = true
    },
    show_settings: function () {
      this.cache_user = {}
      this.cache_user['preferred_working_seconds_per_day'] = this.active_user['preferred_working_seconds_per_day']

      this.settings_visible = true
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = false
      this.editmeal_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_signin: function () {
      this.settings_visible = false
      this.signin_visible = true
      this.signup_visible = false
      this.meals_visible = false
      this.editmeal_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_signup: function () {
      this.signin_visible = false
      this.settings_visible = false
      this.signup_visible = true
      this.meals_visible = false
      this.editmeal_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_meals: function () {
      this.edit_meal = null
      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = true
      this.editmeal_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_users: function () {
      this.edit_user = null
      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.meals_visible = false
      this.editmeal_visible = false
      this.users_visible = true
      this.edituser_visible = false
    }

  }
}
</script>

<style lang="scss">
@charset "utf-8";
@import "~bulma/bulma";

[v-cloak] { display: none; }

</style>
