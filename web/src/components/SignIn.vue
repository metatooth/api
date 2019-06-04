<template>
  <section class="section">
    <div class="columns">
      <div class="column is-4 is-offset-4">
        <div class="field">
          <p class="control has-icons-left">
            <input
              v-model="username"
              class="input"
              type="text"
              placeholder="Username"
            >
            <span class="icon is-small is-left">
              <i
                class="fa fa-user"
                aria-hidden="true"
              />
            </span>
          </p>
        </div>
        <div class="field">
          <p class="control has-icons-left">
            <input
              v-model="password" 
              class="input" 
              type="password" 
              placeholder="Password" 
              @keyup.enter="signin()"
            >
            <span class="icon is-small is-left">
              <i
                class="fa fa-lock"
                aria-hidden="true"
              />
            </span>
          </p>
        </div>
        <div class="field is-grouped">
          <p class="control">
            <a
              class="button is-primary"
              :disabled="!isComplete"
              @click="signin"
            >Sign In</a>
          </p>
          <p class="control">
            <a
              class="button is-text"
              @click="signup"
            >Or Sign Up</a>
          </p>
        </div>
        <p class="help is-danger">
          {{ error }}
        </p>
      </div>
    </div>
  </section>
</template>

<script>
import AuthService from '../api-services/auth'

export default {
    props: {
        onSignin: {
            type: Function,
            default: function (token) {
                return null
            }
        },
        onSignup: {
            type: Function,
            default: function () {
                return null
            }
        }
    },
    data: function () {
        return {
            username: '',
            password: '', 
            error: ''
        }
    },
    computed: {
      isComplete: function () {
        return (this.username.length != 0 && this.password.length > 7)
      }
    },
    methods: {
      signin: function() {
        AuthService.signin({ username: this.username, password: this.password })
          .then(response => {
            this.username = ''
            this.password = ''
            this.error = ''
            this.onSignin(response.data)
          }).catch(error => {
            this.error = error
            console.log(error)
          })
      },
      signup: function() {
        this.username = ''
        this.password = ''
        this.error = ''
        this.onSignup()
      }
    }
}
</script>

<style>
</style>