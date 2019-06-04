<template>
  <section class="section">
    <div class="field">
        <div class="control">
            <input type="number" v-model="meal.calories">
        </div>
    </div>
  </section>
</template>

<script>
import MealsService from '../api-services/meals.js'

export default {
    props: {
        meal: {
            type: Object
        }
    }
}
</script>

<style>
</style>