<template>
  <section class="section">
    <div class="field">
      <div class="control">
        <label for="expected_daily_calories">Expected Daily Calories</label>
        <input
          v-model="record.expected_daily_calories"
          type="number"
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
          class="button is-text"
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
            error: ''
        }
    },
    methods: {
        cancel: function () {
            this.record['expected_daily_calories'] = this.cache['expected_daily_calories']
            this.onClose()
        },
        save: function () {
            this.error = ''
            UsersService.update(this.record['id'], this.record, this.token)
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