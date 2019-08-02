<template>
  <section class="section">
    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">E-mail</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <input
              v-model="record.email"
              class="input"
              type="text"
              disabled=true
            >
          </div>
        </div>
      </div>
    </div>

    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">Role</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
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
      </div>
    </div>
    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">Preferred Working Hours per Day</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <input
              v-model.number="preferred_working_hours_per_day"
              class="input"
              type="number"
              placeholder="How many hours preferred per day?"
            >
          </div>
        </div>
      </div>
    </div>

    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">Password</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <input
              v-model="password"
              class="input"
              type="password"
              placeholder="Leave blank unless changing password."
            >
          </div>
        </div>
      </div>
    </div>
    <div class="field is-horizontal">
      <div class="field-label" />
      <div class="field-body">
        <div class="field is-grouped">
          <div class="control">
            <a
              class="button is-primary"
              :disabled="!isComplete"
              @click="save()"
            >Save</a>
          </div>
          <div class="control">
            <a
              class="button is-light"
              @click="cancel()"
            >Cancel</a>
          </div>
        </div>
      </div>
    </div>
    <p class="help is-danger"> 
      {{ error }}
    </p>
  </section>
</template>

<script>
import usersService from '../api-services/users.js'

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
            preferred_working_hours_per_day: 0,
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

            return (this.record.email.length > 0 && 
              this.record.type.length > 0 && 
              this.preferred_working_hours_per_day &&
              pcheck)
        }
    },
    created: function () {
      this.preferred_working_hours_per_day = this.record.preferred_working_seconds_per_day / 3600
    },
    methods: {
        cancel: function () {
            this.record['email'] = this.cache['email']
            this.record['role'] = this.cache['role']
            this.record['preferred_working_seconds_per_day'] = this.cache['preferred_working_seconds_per_day']
            this.onClose()
        },
        save: function () {
            let user = {}
            this.record.preferred_working_seconds_per_day = this.preferred_working_hours_per_day * 3600
            user['email'] = this.record.email
            user['type'] = this.record.type
            user['preferred_working_seconds_per_day'] = this.record.preferred_working_seconds_per_day
            if (this.password.length > 7) {
                user['password'] = this.password
            }
 
            usersService.update(this.record['id'], user, this.token)
              .then(response => {
                console.log(response)
                console.log(response.data)
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