<template>
  <section class="section">
    <nav class="level">
      <div class="level-item has-centered-text">
        <input
          v-model.trim="text"
          type="text"
          placeholder="Description"
        >
      </div>
      <div class="level-item has-centered-text">
        <input
          v-model="calories"
          type="number"
          placeholder="Calories"
          @keyup.enter="save()"
        >
      </div>
      <div class="level-item has-centered-text">
        <a
          class="button is-primary"
          :disabled="!isComplete"
          @click="save()"
        >Save</a>
      </div>
    </nav>
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
            
          }
        },
        token: {
          type: String,
          default: ''
        }
    },
    data: function () {
      return {
        text: '',
        calories: ''
      }
    },
    computed: {
      isComplete: function () {
        return (this.text.length != 0 && this.calories.length != 0)
      }
    },
    methods: {
      clearMeal: function () {
        this.text = ''
        this.calories = ''
      },
      edit: function(meal) {
        this.onEdit(meal)
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
      }
    }  
  }
</script>

<style>
</style>