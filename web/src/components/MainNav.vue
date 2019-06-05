<template>
<section class="section">
  <nav class="level">
    <div class="level-left">
      <p class="title">
        Calorie Tracker
      </p>
    </div>
    <div
      v-if="token"
      class="level-right"
    >
      <aside class="menu">
        <ul class="menu-list">
          <li>
            <a
              href="#"
              @click="settings"
            >
              <span class="icon has-icon-left">
                <i class="fas fa-user-cog" />
              </span>
              Settings
            </a>
          </li>
          <li>
            <a
              href="#"
              @click="signout"
            >
              <span class="icon has-icon-left">
                <i class="fas fa-sign-out-alt" />
              </span>
              Sign Out
            </a>
          </li>
        </ul>
      </aside>
    </div>
  </nav>
  </section>
</template>

<script>
import AuthService from '../api-services/auth'
import UsersService from '../api-services/users'

export default {
    props: {
        token: {
            type: String,
            default: ''
        },
        onSettings: {
          type: Function,
          default: function () {
            return null
          }
        },
        onSignout: {
            type: Function,
            default: function () {
              return null
            }
        }
    },
    methods: {
        settings: function () {
          this.onSettings()
        },
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