<template>
  <div id="app" class="container">
    <section v-show="signup_visible" ref="signup" class="section signup">
      <nav class="level">
        <div class="level-left">
          <p class="title">Calorie Tracker</p>
        </div>
      </nav>
      <div class="columns">
        <div class="column is-4 is-offset-4">
          <div class="field">
            <p class="control has-icons-left">
              <input class="input" ype="text" v-model="username" placeholder="Username" />
              <span class="icon is-small is-left">
                <i class="fa fa-user" aria-hidden="true"></i>
              </span>
            </p>
          </div>
        <div class="field">
        <p class="control has-icons-left">
          <input class="input" type="password" v-model="password" placeholder="Password" />
            <span class="icon is-small is-left">
              <i class="fa fa-lock" aria-hidden="true"></i>
            </span>
          </p>
        </div>
        <div class="field">
        <p class="control has-icons-left">
          <input class="input" type="password" v-model="confirm_password" placeholder="Confirm password" />
            <span class="icon is-small is-left">
              <i class="fa fa-lock" aria-hidden="true"></i>
            </span>
          </p>
        </div>
        <div class="field is-grouped">
          <p class="control">
            <a class="button is-primary" @click="signup">Sign Up</a>
          </p>
          <p class="control">
            <a class="button is-light" @click="show_signin">Cancel</a>
          </p>
        </div>
        <p class="help is-danger"> 
          {{ signup_error }}
        </p>
      </div>
      </div>
    </section>
    <section v-show="signin_visible" ref="signin" class="section signin">
      <nav class="level">
        <div class="level-left">
          <p class="title">Calorie Tracker</p>
        </div>
      </nav>
      <div class="columns">
        <div class="column is-4 is-offset-4">
          <div class="field">
            <p class="control has-icons-left">
              <input class="input" type="text" v-model="username" placeholder="Username" />
              <span class="icon is-small is-left">
                <i class="fa fa-user" aria-hidden="true"></i>
              </span>
            </p>
        </div>
        <div class="field">
          <p class="control has-icons-left">
            <input class="input" 
              type="password" 
              v-model="password" 
              placeholder="Password" 
              @keyup.enter="signin()"/>
            <span class="icon is-small is-left">
              <i class="fa fa-lock" aria-hidden="true"></i>
            </span>
          </p>
        </div>
        <div class="field is-grouped">
          <p class="control">
            <a class="button is-primary" @click="signin">Sign In</a>
          </p>
          <p class="control">
            <a class="button is-text" @click="show_signup">Or Sign Up</a>
          </p>
        </div>
        <p class="help is-danger">
          {{ signin_error }}
        </p>

        </div>
      </div>
    </section>
    <section v-show="tracker_visible" class="section tracker">
      <nav class="level">
        <div class="level-left">
          <p class="title">Calorie Tracker</p>
        </div>
        <div class="level-right">
          <p><a href="#" @click="signout">Sign Out</a></p>
        </div>
      </nav>
      <nav class="level">
        <div class="level-item has-centered-text">
          <input v-model.trim="text" type="text" placeholder="Description" />
        </div>
        <div class="level-item has-centered-text">
          <input v-model="calories" type="number" placeholder="Calories" />
        </div>
        <div class="level-item has-centered-text">
          <a class="button is-primary"
            :disabled=!is_complete
            @click="save">Save</a>
        </div>
      </nav>
      <section class="main" v-show="meals.length" v-cloak>
        <nav v-for="meal in meals" 
          class="level meal-list editing"
          :key="meal['id']"
          :class = "{ highlight: meal.overlimit }">
          <div class="level-item" :class="{ editing: is_editing(meal, 'taken') }">
            <div class="view">
              <label @dblclick="edit(meal, 'taken')">{{ meal.taken }}</label>
            </div>
            <input class="edit" type="text"
              v-model="meal.taken"
              v-meal-taken-focus="is_editing(meal, 'taken')"
              @blur="done(meal)"
              @keyup.enter="done(meal)"
              @keyup.esc="cancel(meal, 'taken')">
          </div>
          <div class="level-item" :class="{ editing: is_editing(meal, 'text') }">
            <div class="view">
              <label @dblclick="edit(meal, 'text')">{{ meal.text }}</label>
            </div>
            <input class="edit" type="text"
            v-model.trim="meal.text"
            v-meal-text-focus="is_editing(meal, 'text')"
            @blur="done(meal)"
            @keyup.enter="done(meal)"
            @keyup.esc="cancel(meal, 'text')">
          </div>
          <div class="level-item" :class="{ editing: is_editing(meal, 'calories') }"> 
              <div class="view">
                <label @dblclick="edit(meal, 'calories')">{{ meal.calories }}</label>
              </div>
              <input class="edit" type="number"
                v-model="meal.calories"
                v-meal-calorie-focus="is_editing(meal, 'calories')"
                @blur="done(meal)"
                @keyup.enter="done(meal)"
                @keyup.esc="cancel(meal, 'calories')"
              >
          </div>
          <div class="level-item"> 
            <a class="is-danger" @click="remove(meal)">
              <span class="icon">
                <i class="fa fa-times" aria-hidden="true"></i>
              </span>
            </a>
          </div>
        </nav>
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
      access_token: '',
      before_edit_cache: '',
      calories: '',
      confirm_password: '',
      edited_attr: '',
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
    is_complete: function () {
      return (this.text.length != 0 && this.calories.length != 0)
    }
  },
  methods: {
    cancel: function(meal, attr) {
      this.edited_meal = null
      this.edited_attr = ''
      meal[attr] = this.before_edit_cache
    },
    clear_credentials: function () {
      this.username = ''
      this.password = ''
      this.confirm_password = ''
    },
    clear_meal: function () {
      this.text = ''
      this.calories = ''
    },
    done: function (meal) {
      if (!this.edited_meal) {
        return
      }
      const scope = this
      MealsService.update(meal['id'], meal, this.access_token)
        .then( function (response) {
          scope.edited_meal = null
          scope.edited_attr = ''
        }).catch( function (error) {
          console.log(error)
        })
    },
    edit: function(meal, attr) {
      this.before_edit_cache = meal[attr]
      this.edited_attr = attr
      this.edited_meal = meal
    },
    fetch_meals: function() {
      MealsService.get_all(this.access_token).then(response => {
        this.meals = []
        for (let i = 0; i < response.data.length; ++i) {
          this.meals.push(response.data[i])
        }
      }).catch(e => {
        console.log(e)
      })
    },
    is_editing: function(meal, attr) {
      return ((meal == this.edited_meal) && (attr = this.edited_attr))
    },
    remove: function (meal) {
      const doomed_id = meal.id
      this.meals.splice(this.meals.indexOf(meal), 1)

      console.log('Removing ' + doomed_id)
      MealsService.destroy(doomed_id, this.access_token)
        .then(response => {
          console.log(response)
        }).catch(e => {
          console.log(e)
        })
    },
    save: function () {
      this.meals.push({ taken: new Date(), text: this.text, calories: this.calories })
      this.clear_meal()
    },
    show_signin: function () {
      this.clear_credentials()
      this.signin_visible = true
      this.signup_visible = false
      this.tracker_visible = false
    },
    show_signup: function () {
      this.clear_credentials()
      this.signin_visible = false
      this.signup_visible = true
      this.tracker_visible = false
    },
    show_tracker: function () {
      this.signin_visible = false
      this.signup_visible = false
      this.tracker_visible = true
    },    
    signup: function () {
      this.signup_error = ''
      AuthService.signup({ username: this.username, password: this.password })
      .then(response => {
        scope.show_signin()
      }).catch(e => {
        this.signup_error = e
        console.log(e)
      })
    },
    signin: function () {
      this.signin_error = ''
      AuthService.signin({ username: this.username, password: this.password })
      .then(response => {
        this.access_token = response.data
        this.clear_credentials()
        this.show_tracker()
        this.fetch_meals()
      }).catch(e => {
        this.signin_error = e
        console.log(e)
      })
    },
    signout: function () {
      this.clear_access_token = ''
      AuthService.signout()
      .then(response => {
        console.log(response.data)
        this.show_signin()
      }).catch(e => {
        console.log(e)
      })
    }
  },
  directives: {
    'meal-taken-focus': function (el, binding) {
      if (binding.value) {
        el.focus()
      }
    },
    'meal-text-focus': function (el, binding) {
      if (binding.value) {
        el.focus()
      }
    },
    'meal-calorie-focus': function (el, binding) {
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

[v-cloak] { display: none; }

</style>
