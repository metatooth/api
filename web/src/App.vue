<template>
  <div id="app">
    <section v-show="show_signup" ref="signup" class="signup">
      <div class="control">
        <input v-model="username" placeholder="Username" />
      </div>
      <div class="control">
        <input v-model="password" placeholder="Password" />
      </div>
      <div class="control">
        <input v-model="confirm_password" placeholder="Confirm password" />
      </div>
      <div class="control">
        <button class="button" @click="signup">Sign Up</button>
      </div>
    </section>
    <section v-show="show_signin" ref="signin" class="signin">
      <div class="control">
        <input v-model="username" placeholder="Username" />
      </div>
      <div class="control">
        <input v-model="password" placeholder="Password" />
      </div>
      <div class="control">
        <button class="button" @click="signin">Sign In</button>
      </div>
      <div class="errors">
        {{ signin_error }}
      </div>
    </section>
    <section v-show="show_tracker" class="tracker">
      <header class="header">
        <h1>calories</h1>
        <input v-model="text" placeholder="Description" />
        <input v-model="calories" placeholder="Calories" />
        <button class="button" :disabled=!isComplete @click="save">Save</button>
      </header>
      <section class="main">

      </section>
      <footer class="footer">
      </footer>
    </section>
  </div>
</template>

<script>
import AuthService from './api-services/auth'
import MealsService from './api-services/meals'
import { mapState } from 'vuex'
import store from './store'

export default {
  name: 'app',
  data () {
    return {
      show_signup: false,
      show_signin: true,
      show_tracker: false,
      signin_error: '',
      username: '',
      password: '',
      confirm_password: '',
      text: '',
      calories: ''
    }
  },
  computed: {
    ...mapState([
      'access_token',
      'user',
      'meals',
      'users'
    ]),
    isComplete: function () {
      return (this.$data.text.length != 0 && this.$data.calories.length != 0)
    }
  },
  methods: {
    cancel: function () {
      this.$data.text = ''
      this.$data.calories = ''
    },
    save: function () {
      console.log(this.$data.access_token)
      const scope = this
      MealsService.create({ taken: new Date(), text: this.$data.text, calories: this.$data.calories },
        scope.$data.access_token)
      .then(response => {
        console.log(response)
        scope.cancel()
      }).catch(e => {
        console.log(e)
      })
    },
    signup: function () {

    },
    signin: function () {
      const scope = this
      scope.$data.signin_error = ''
      AuthService.signin({ username: this.$data.username, password: this.$data.password })
      .then(response => {
        console.log(response)
        console.log(response.data)
        scope.$data.access_token = response.data
        this.$data.show_signin = false
        this.$data.show_tracker = true
      }).catch(e => {
        scope.$data.signin_error = e
        console.log(e)
      })
    },
    signout: function () {

    }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
