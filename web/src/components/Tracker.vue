<template>
  <section class="section">
    <section class="section">
      <div class="field is-grouped">
        <div class="control">
          <label>From Date
            <input
              v-model="fromDate"
              type="text"
            >
          </label>

          <label>To Date
            <input
              v-model="toDate"
              type="text"
            >
          </label>
        </div>
      </div>

      <div class="field is-grouped">
        <div class="control">
          <label>Between
            <input
              v-model="fromTime"
              type="text"
            >
          </label>

          <label>And
            <input
              v-model="toTime"
              type="text"
            >
          </label>
        </div>
      </div>      
      <div class="field">
        <div class="control">
          <a
            class="button is-primary"
            @click="filter"
          >Filter</a>
        </div>
      </div>
      <p class="help is-danger">
        {{ filter_errors }}
      </p>
    </section>
    <section
      v-show="meals.length"
      v-cloak
      class="main"
    >
      <table class="table">
        <thead>
          <tr>
            <th>Meal At</th>
            <th>Description</th>
            <th>Calories</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="meal in meals" 
            :key="meal.id"
            class="meal-list"
            :class="{ highlight: meal.overlimit }"
          >
            <td>
              {{ meal.taken }}
            </td>
            <td>
              {{ meal.text }}
            </td>
            <td>
              {{ meal.calories }}
            </td>
            <td>
              <a
                class="button is-primary"
                @click="edit(meal)"
              >
                <span class="icon">
                  <i class="fas fa-edit" />
                </span>
              </a>
                &nbsp;
              <a
                class="button is-danger"
                @click="remove(meal)"
              >
                <span class="icon">
                  <i class="fas fa-times" />
                </span>
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
    <section class="section">
      <div class="field">
        <div class="control">
          <label>Description
            <input
              v-model.trim="text"
              type="text"
              placeholder="Description"
            >
          </label>
        </div>
      </div>
      <div class="field">
        <div class="control">
          <label>Calories
            <input
              v-model="calories"
              type="number"
              placeholder="Calories"
              @keyup.enter="save()"
            >
          </label>
        </div>
      </div>
      <div class="field">
        <div class="control">
          <a
            class="button is-primary"
            :disabled="!isComplete"
            @click="save()"
          >Save</a>
        </div>
      </div>
    </section>
  </section>
</template>

<script>
import MealsService from '../api-services/meals'

export default {
  props: {
    meals: {
      type: Array,
      default: function () {
        return new Array()
      }
    },
    onEdit: {
      type: Function,
        default: function () {
          return null        
        }
    },
    token: {
      type: String,
      default: ''
    }
  },
  data: function () {
    return {
      calories: '',
      fromDate: '',
      fromTime: '',
      text: '',
      toDate: '',
      toTime: '',
      errors: '',
      filter_errors: ''
    }
  },
  computed: {
    isComplete: function () {
      return (this.text.length != 0 && this.calories.length != 0)
    }
  },
  created: function () {
    const d = new Date()
    this.toDate = d.yyyymmdd()
    d.setDate(d.getDate() - 30)
    this.fromDate = d.yyyymmdd()
    this.fromTime = '00:00'
    this.toTime = '24:00'
  },
  methods: {
    clearMeal: function () {
      this.text = ''
      this.calories = ''
    },
    edit: function(meal) {
      this.onEdit(meal)
    },
    filter: function() {
      this.filter_errors = ''
      if (!this.validDate(this.fromDate)) {
        console.log('bad from-date format ' + this.fromDate)
        this.filter_errors = 'From Date must be formatted as YYYY-mm-dd'
      } else if (!this.validDate(this.toDate)) {
        console.log('bad to-date format ' + this.toDate)
        this.filter_errors = 'To Date must be formatted as YYYY-mm-dd'
      } else if (!this.validTime(this.toTime)) {
        console.log('bad to-time format ' + this.toTime)
        this.filter_errors = 'To Time must be formatted as HH:MM'
      } else if (!this.validTime(this.fromTime)) {
        console.log('bad from-time format ' + this.fromTime)
        this.filter_errors = 'From Time must be formatted as HH:MM'
      } else {
        MealsService.get_all(this.token, this.fromDate, this.toDate)
          .then(response => {
            const from = this.fromTime.split(':')
            const to = this.toTime.split(':')
            this.meals = new Array
            for (let i = 0; i < response.data.length; ++i) {
              const taken = new Date(response.data[i].taken)
              if (taken.getHours() >= from[0] && taken.getMinutes() >= from[1]) {
                if (taken.getHours() < to[0]) {
                  this.meals.push(response.data[i])
                } else if (taken.getHours() == to[0] && taken.getMinutes <= to[1]) {
                  this.meals.push(response.data[i])
                }
              }
            }
        }).catch(error => {
          console.log(error)
        })
      }
    },
    remove: function (meal) {
      const doomed_id = meal.id
      this.meals.splice(this.meals.indexOf(meal), 1)

      console.log('Removing ' + doomed_id)
      MealsService.destroy(doomed_id, this.token)
        .then(response => {
          console.log(response)
        }).catch(e => {
          console.log(e)
      })
    },
    save: function () {
      MealsService.create({ taken: new Date(), text: this.text, calories: this.calories }, this.token)
        .then(response => {
          console.log(response)
          console.log(response.data)
          this.meals.push(response.data)
          this.clearMeal()
        }).catch(error => {
          console.log(error)
        })
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