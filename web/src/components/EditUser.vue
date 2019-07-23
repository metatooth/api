<template>
  <section class="section">
    <div class="field">
      <div class="control">
        <label for="taken">Username</label>
        <input
          v-model="record.username"
          type="text"
        >
      </div>
    </div>
    <div class="field">
      <div class="control">
        <label for="text">Role</label>
        <div class="select">
          <select v-model="record.type">
            <option value="User">
              User
            </option>
            <option value="UserManager">
              UserManager
            </option>
            <option value="Admin">
              Admin
            </option>
          </select>
        </div>
      </div>
    </div>
    <div class="field">
      <div class="control">
        <label>Expected Daily Calories</label>
        <input
          v-model="record.preferred_working_seconds_per_day"
          type="number"
          placeholder="How many calories expected per day?"
        >
      </div>
    </div>
    <div class="field">
      <div class="control">
        <label>Password</label>
        <input
          v-model="password"
          type="text"
          placeholder="Leave blank unless changing password."
        >
      </div>
    </div>
    <div class="field is-grouped">
      <p class="control">
        <a
          class="button is-primary"
          :disabled="!isComplete"
          @click="save()"
        >Save</a>
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
  </section>
</template>

<script>
import UsersService from '../api-services/users.js'

export default {
    props: {
        cache: {
            type: Object,
            default: null
        },
        onClose: {
            type: Function,
            default: function () {

            }
        },
        record: {
            type: Object,
            default: null
        },
        token: {
            type: String,
            default: ''
        }
    },
    data: function () {
        return {
            password: '',
            error: ''
        }
    },
    computed: {
        isComplete: function () {
            let pcheck = true
            if (this.password.length > 0) {
                if (this.password.length < 8) {
                    pcheck = false
                }
            }

            return (this.record.username.length > 0 && 
              this.record.type.length > 0 && 
              this.record.preferred_working_seconds_per_day &&
              pcheck)
        }
    },
    methods: {
        cancel: function () {
            this.record['taken'] = this.cache['taken']
            this.record['text'] = this.cache['text']
            this.record['calories'] = this.cache['calories']
            this.onClose()
        },
        save: function () {
            let user = {}
            user['username'] = this.record.username
            user['type'] = this.record.type
            user['preferred_working_seconds_per_day'] = this.record.preferred_working_seconds_per_day
            if (this.password.length > 7) {
                user['password'] = this.password
            }
 
            UsersService.update(this.record['id'], user, this.token)
              .then(response => {
                this.onClose()
              }).catch(error => {
                  console.log(error)
                  this.error = error
              })
        }
    }
}
</script>

<style>
</style>