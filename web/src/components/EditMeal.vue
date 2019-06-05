<template>
  <section class="section">
    <p class="subtitle">
      Edit meal
    </p>
    <div class="field">
      <label class="label">Day</label>
      <div class="control">
        <input
          v-model="day"
          type="text"
        >
      </div>
    </div>
    <div class="field">
      <label class="label">At</label>
      <div class="control">
        <input
          v-model="time"
          type="text"
        >
      </div>
    </div>
    <div class="field">
      <label class="label">Description</label>
      <div class="control">
        <input
          v-model="record.text"
          type="text"
        >
      </div>
    </div>
    <div class="field">
      <label class="label">Calories</label>
      <div class="control">
        <input
          v-model="record.calories"
          type="number"
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
import MealsService from '../api-services/meals.js'

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
            day: '',
            error: '',
            time: ''
        }
    },
    computed: {
        isComplete: function () {
            return (this.day.length == 10 && this.time.length == 5 && this.record.text.length > 0 && this.record.calories > 0)
        }
    },
    created: function () {
      this.day = new Date(this.record.taken).yyyymmdd()
      this.time = new Date(this.record.taken).hhmm()
    },
    methods: {
        cancel: function () {
            this.record['taken'] = this.cache['taken']
            this.record['text'] = this.cache['text']
            this.record['calories'] = this.cache['calories']
            this.onClose()
        },
        save: function () {
          this.errors = ''
            if (!this.validDate(this.day)) {
              this.errors = 'Day must be in the format YYYY-MM-DD'
            } else if (!this.validTime(this.time)) {
              this.errors = 'Time must be in the format HH:MM'
            } else {
              const day = this.day.split('-')
              const time = this.time.split(':')
              this.record.taken = new Date(day[0], day[1]-1, day[2], time[0], time[1])   
              MealsService.update(this.record['id'], this.record, this.token)
                .then(response => {
                  this.onClose()
                }).catch(error => {
                  console.log(error)
                  this.error = error
              })
            }
        },
        validDate: function(str) {
          const re = /^\d\d\d\d-\d\d-\d\d$/
          return re.test(str)
        },
        validTime: function(str) {
          const re = /^\d\d:\d\d$/
          return re.test(str)
        }
      }
    }
</script>

<style>
</style>