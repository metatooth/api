<template>
  <section class="section">
    <div class="field">
        <div class="control">
            <label for="taken">Meal At</label>
            <input type="text" v-model="record.taken">
        </div>
    </div>
    <div class="field">
        <div class="control">
            <label for="text">Description</label>
            <input type="text" v-model="record.text">
        </div>
    </div>
    <div class="field">
        <div class="control">
            <label for="calories">Calories</label>
            <input type="number" v-model="record.calories">
        </div>
    </div>
    <div class="field is-grouped">
        <p class="control">
            <a class="button is-primary" :disabled="!isComplete" @click="save()">Save</a>
        </p>
        <p class="control">
            <a class="button is-light" @click="cancel()">Cancel</a>
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
            type: Object
        },
        onClose: {
            type: Function,
            default: function () {

            }
        },
        record: {
            type: Object
        },
        token: {
            type: String
        }
    },
    data: function () {
        return {
            error: ''
        }
    },
    computed: {
        isComplete: function () {
            return (this.record.taken.length > 0 && this.record.text.length > 0 && this.record.calories > 0)
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
            MealsService.update(this.record['id'], this.record, this.token)
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