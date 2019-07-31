<template>
  <section class="section">
    <p class="subtitle">
      Hello, {{ record.username }}!
    </p>
    <div class="field">
      <label class="label">Preferred Working Hours per Day</label>
      <div class="control">
        <input
          v-model="preferred_working_hours_per_day"
          class="input"
          type="number"
          placeholder="e.g. 8"
        >
      </div>
    </div>
    <div class="field is-grouped">
      <div class="control">
        <a
          class="button is-primary"
          @click="save()"
        >Save</a>
        <a
          class="button is-light"
          @click="cancel()"
        >Cancel</a>
      </div>
    </div>
    <p class="help is-danger">
      {{ error }}
    </p>
  </section>
</template>

<script>
import UsersService from '../api-services/users'

export default {
    props: {
        onClose: {
            type: Function,
            default: function () {

            }
        },
        cache: {
            type: Object,
            default: null
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
          preferred_working_hours_per_day: 8,
          error: ''
        }
    },
    created: function () {
      this.preferred_working_hours_per_day = this.record.preferred_working_seconds_per_day / 3600
    },
    methods: {
        cancel: function () {
            this.record.preferred_working_seconds_per_day = this.cache.preferred_working_seconds_per_day
            this.onClose()
        },
        save: function () {
            this.error = ''
            console.log(this.preferred_working_hours_per_day)
            this.record.preferred_working_seconds_per_day = this.preferred_working_hours_per_day * 3600
            UsersService.update(this.record['id'], this.record, this.token)
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