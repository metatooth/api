<template>
  <section class="section">
    <hr>
    <p class="subtitle">
      Query meals
    </p>
    <div class="field is-grouped">
      <div class="control">
        <label>From
          <input
            v-model="fromDate"
            size="10"
            type="text"
            placeholder="For example, 2007-08-03"
          >
        </label>

        <label>to
          <input
            v-model="toDate"
            size="10"
            type="text"
            placeholder="For example, 2009-09-11"
          >
        </label>
        <label>between
          <input
            v-model="fromTime"
            size="5"
            type="text"
            placeholder="For example, 17"
          >
        </label>
        <label>and
          <input
            v-model="toTime"
            size="5"
            type="text"
            placeholder="For example, 17:30"
          >
        </label>
        <a
          class="button is-primary"
          @click="filter"
        >Query</a>
      </div>
    </div> 
    <hr>  
    <table
      v-show="meals.length"
      v-cloak
      class="table"
    >
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
          v-for="meal in decoratedMeals" 
          :key="meal.id"
          class="meal-list"
          :class="{ highlight: meal.overlimit }"
        >
          <td>
            {{ meal.yyyymmdd }} {{ meal.hhmm }}
          </td>
          <td>
            {{ meal.text }}
          </td>
          <td>
            {{ meal.calories }}
          </td>
          <td>
            <a
              class="button"
              @click="edit(meal)"
            >
              <span class="icon">
                <i class="fas fa-edit" />
              </span>
            </a>
                &nbsp;
            <a
              class="button"
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
    <hr>
    <p class="subtitle">
      Add a meal
    </p>
    <div class="field">
      <label class="label">Description</label>
      <div class="control">
        <input
          v-model.trim="text"
          type="text"
          placeholder="Description"
        >
      </div>
    </div>
    <div class="field">
      <label class="label">Calories</label>
      <div class="control">
        <input
          v-model="calories"
          type="number"
          placeholder="Calories"
          @keyup.enter="save()"
        >
      </div>
    </div>
    <div class="field is-grouped">
      <div class="control">
        <a
          class="button is-primary"
          :disabled="!isComplete"
          @click="save()"
        >Save</a>
        <a
          class="button is-text"
          @click="clearMeal()"
        >Cancel</a>
      </div>
    </div>
  </section>
</template>

<script>
import MealsService from '../api-services/meals'

export default {
  props: {
    expectedDailyCalories: {
      type: Number,
      default: 2000
    },
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
    },
    decoratedMeals: function () {
      const daily = new Object
      for (let i = 0; i < this.meals.length; ++i) {
        const taken = new Date(this.meals[i].taken)
        if (!daily[taken.yyyymmdd()]) {
          daily[taken.yyyymmdd()] = 0 
        }
      
        daily[taken.yyyymmdd()] = daily[taken.yyyymmdd()] + parseInt(this.meals[i].calories)
      }
      const from = this.fromTime.split(':')
      if (!from[1]) {
        from[1] = 0
      }

      const to = this.toTime.split(':')
      if (!to[1]) {
        to[1] = 0
      }

      const filtered = new Array
      for (let i = 0; i < this.meals.length; ++i) {
        const meal = this.meals[i]
        const taken = new Date(meal.taken)
        
        meal.overlimit = (daily[taken.yyyymmdd()] > this.expectedDailyCalories)
        meal.yyyymmdd = taken.yyyymmdd()
        meal.hhmm = taken.hhmm()
        
        if (taken.getHours() >= from[0] && taken.getMinutes() >= from[1]) {
          if (taken.getHours() < to[0]) {
            filtered.push(this.meals[i])
          } else if (taken.getHours() == to[0] && taken.getMinutes <= to[1]) {
            filtered.push(meal)
          }
        }
      }
      return filtered.sort(function (a, b) {
        if (new Date(a.taken) > new Date(b.taken)) {
          return -1
        } else if (new Date(a.taken) < new Date(b.taken)) {
          return 1
        } else {
          return null
        }
      })
    }
  },
  created: function () {
    const d = new Date()
    this.toDate = d.yyyymmdd()
    d.setDate(d.getDate() - 30)
    this.fromDate = d.yyyymmdd()
    this.fromTime = '0'
    this.toTime = '24'
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
      } else {
        MealsService.get_all(this.token, this.fromDate, this.toDate)
          .then(response => {
            this.meals = response.data
        }).catch(error => {
          console.log(error)
        })
      }
    },
    remove: function (meal) {
      MealsService.destroy(meal.id, this.token)
        .then(response => {
          this.meals.splice(this.meals.indexOf(meal), 1)
        }).catch(error => {
          console.log(error)
      })
    },
    save: function () {
      MealsService.create({ taken: new Date(), text: this.text, calories: this.calories }, this.token)
        .then(response => {
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
.section {
  padding-bottom: 0px
}

.table {
  width: 100%
}

.meal-list {
  background: #66bb66
}

.highlight {
  background: #bb6666
}
</style>