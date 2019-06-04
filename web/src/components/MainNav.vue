<template>
    <section class="section">
      <nav class="level">
        <div class="level-left">
          <p class="title">Calorie Tracker</p>
        </div>
        <div class="level-right" v-if="token">
          <p><a href="#" @click="signout">Sign Out</a></p>
        </div>
      </nav>
    </section>
</template>

<script>
import AuthService from '../api-services/auth'

export default {
    props: {
        token: {
            type: String,
            default: ''
        },
        onSignout: {
            type: Function,
            default: function () {

            }
        }
    },
    methods: {
        signout: function () {
            AuthService.signout().then(response => {
                this.onSignout()
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>

<style>
</style>