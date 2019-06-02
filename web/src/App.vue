<template>
  <div id="app" class="container">
    <section v-show="signup_visible" ref="signup" class="section signup">
      <div class="columns">
        <div class="column is-4 is-offset-4">

          <div class="field">
        <p class="control has-icons-left">
          <input class="input" ype="text" v-model="username" placeholder="Username" />
          <span class="icon is-small is-left">
            <i class="fa fa-user"></i>
          </span>
        </p>
        </div>
        <div class="field">
        <p class="control has-icons-left">
          <input class="input" type="password" v-model="password" placeholder="Password" />
        <span class="icon is-small is-left">
              <i class="fa fa-lock"></i>
            </span>
          </p>
        </div>
        <div class="field">
        <p class="control has-icons-left">
          <input class="input" type="password" v-model="confirm_password" placeholder="Confirm password" />
            <span class="icon is-small is-left">
              <i class="fa fa-lock"></i>
            </span>
          </p>
        </div>
        <div class="field">
        <p class="control">
          <button type="submit" class="button is-success" @click="signup">Sign Up</button>
        </p>
        </div>
        <div class="errors"> 
          {{ signup_error }}
        
        </div>
        <div>
          <a href="#" @click="show_signin">Cancel</a>
        </div>
      </div>
    </div>
    </section>
    <section v-show="signin_visible" ref="signin" class="section signin">
      <div class="columns">
        <div class="column is-4 is-offset-4">
          <div class="field">
            <p class="control has-icons-left">
              <input class="input" type="text" v-model="username" placeholder="Username" />
              <span class="icon is-small is-left">
                <i class="fa fa-user"></i>
              </span>
            </p>
        </div>
        <div class="field">
          <p class="control has-icons-left">
            <input class="input" type="password" v-model="password" placeholder="Password" />
            <span class="icon is-small is-left">
              <i class="fa fa-lock"></i>
            </span>
          </p>
        </div>
        <div class="field">
          <p class="control">
            <button type="submit" class="button is-success" @click="signin">Sign In</button>
          </p>
        </div>
        <div class="errors">
          {{ signin_error }}
        </div>
        <div>Or <a href="#" @click="show_signup">Sign Up</a></div>

        </div>
      </div>
    </section>
    <section v-show="tracker_visible" class="tracker">
      <header class="header">
        <h1>Calorie Tracker</h1>
        <input v-model="text" placeholder="Description" />
        <input v-model="calories" placeholder="Calories" />
        <button class="button" :disabled=!isComplete @click="save">Save</button>
      </header>
      <section class="main" v-show="meals.length">
        <ul class="meal-list">
          <li v-for="meal in meals" class="meal" :key="meal.id" :class = "{ highlight: meal.overlimit }">
            <div class="view">
              <label @dblclick="edit(meal, 'taken')">{{ meal.taken }}</label>
              <label @dblclick="edit(meal, 'text')">{{ meal.text }}</label>
              <label @dblclick="edit(meal, 'calories')">{{ meal.calories }}</label>
              <button class="destroy" @click="remove(meal)"></button>
            </div>
            <input class="edit" type="text"
              v-model="meal.calories"
              v-meal-focus="meal === edited_meal"   
              @blur="done(meal)"
              @keyup.enter="done(meal)"
              @keyup.esc="cancel(meal)"/>       
          </li>
        </ul>    
      </section>
      <footer class="footer">
      </footer>
    </section>
  </div>
</template>

<script>
import AuthService from './api-services/auth'
import MealsService from './api-services/meals'

export default {
  name: 'app',
  data () {
    return {
      calories: '',
      confirm_password: '',
      edited_meal: null,
      meals: [],
      password: '',
      signin_error: '',
      signin_visible: true,
      signup_error: '',
      signup_visible: false,
      text: '',
      tracker_visible: false,
      username: '',
      users: []
    }
  },
  computed: {
    isComplete: function () {
      return (this.$data.text.length != 0 && this.$data.calories.length != 0)
    }
  },
  methods: {
    clear_credentials: function () {
      this.$data.username = ''
      this.$data.password = ''
      this.$data.confirm_password = ''
    },
    clear_meal: function () {
      this.$data.text = ''
      this.$data.calories = ''
    },
    edit: function(meal, attr) {
    
    },
    fetch_meals: function() {
      const scope = this
      MealsService.get_all(scope.$data.access_token).then(response => {
        scope.$data.meals = []
        for (let i = 0; i < response.data.length; ++i) {
          scope.$data.meals.push(response.data[i])
        }
      }).catch(e => {
        console.log(e)
      })
    },
    remove: function (meal) {
      const scope = this
      MealsService.destroy(meal.id, this.$data.access_token)
        .then(response => {
          console.log(response.data)
          scope.fetch_meals()
        }).catch(e => {
          console.log(e)
        })
    },
    save: function () {
      console.log(this.$data.access_token)
      const scope = this
      MealsService.create({ taken: new Date(), text: this.$data.text, calories: this.$data.calories },
        scope.$data.access_token)
      .then(response => {
        console.log(response)
        scope.clear_meal()
        scope.fetch_meals()
      }).catch(e => {
        console.log(e)
      })
    },
    show_signin: function () {
      this.$data.signin_visible = true
      this.$data.signup_visible = false
      this.$data.tracker_visible = false
      this.clear_credentials()
    },
    show_signup: function () {
      this.$data.signin_visible = false
      this.$data.signup_visible = true
      this.$data.tracker_visible = false
      this.clear_credentials()
    },
    show_tracker: function () {
      this.$data.signin_visible = false
      this.$data.signup_visible = false
      this.$data.tracker_visible = true
    },    
    signup: function () {
      const scope = this
      scope.$data.signup_error = ''
      AuthService.signup({ username: scope.$data.username, password: scope.$data.password })
      .then(response => {
        console.log(response.data)
        scope.show_signin()
      }).catch(e => {
        scope.$data.signup_error = e
        console.log(e)
      })
    },
    signin: function () {
      const scope = this
      scope.$data.signin_error = ''
      AuthService.signin({ username: this.$data.username, password: this.$data.password })
      .then(response => {
        console.log(response.data)
        scope.$data.access_token = response.data
        scope.show_tracker()
        scope.fetch_meals()
      }).catch(e => {
        scope.$data.signin_error = e
        console.log(e)
      })
    },
    signout: function () {

    }
  },
  directives: {
    'meal-focus': function (el, binding) {
      if (binding.value) {
        el.focus()
      }
    }
  }

}
</script>

<style lang="scss">
@charset "utf-8";
@import "~bulma/bulma";
</style>
