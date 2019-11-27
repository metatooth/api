<template>
  <section class="section">
    <div class="columns">
      <div class="column is-4 is-offset-4">
        <div class="field">
          <p class="control has-icons-left">
            <input
              v-model="email"
              class="input"
              type="text"
              placeholder="E-mail"
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
            >
            <span class="icon is-small is-left">
              <i
                class="fa fa-lock"
                aria-hidden="true"
              />
            </span>
          </p>
        </div>
        <div class="field">
          <p class="control has-icons-left">
            <input
              v-model="confirm_password"
              class="input"
              type="password"
              placeholder="Confirm password"
              @keyup.enter="signup()"
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
              @click="signup()"
            >Sign Up</a>
          </p>
          <p class="control">
            <a
              class="button is-light"
              @click="cancel()"
            >Cancel</a>
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
            onClose: {
                type: Function,
                default: function() {
                    return null
                }
            }
        },
        data: function () {
            return {
                email: '',
                password: '',
                confirm_password: '',
                error: ''
            }
        },
        computed: {
          isComplete: function() {
            return (this.email.length != 0 && 
              this.password.length > 7 &&
              this.confirm_password == this.password)
          }
        },
        methods: {
            cancel: function () {
                this.onClose()
            },
            signup: function () {
              if (this.isComplete) {
                AuthService.signup({email: this.email, password: this.password})
                  .then(response => {
                    this.email = ''
                    this.password = ''
                    this.confirm_password = ''
                    this.error = ''
                    console.log(response)
                    console.log(response.data)
                    this.onClose()
                  }).catch(error => {
                    console.log(error)
                    this.error = error
                  })
              }
            },
            validEmail: function(str) {
              const re = /^.*@.*\..*$/
              return re.test(str)
            }
        }
      }

    </script>

    <style>
    </style>