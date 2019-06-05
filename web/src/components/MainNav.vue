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
                @click="do_settings"
              >
                <span class="icon has-icon-left">
                  <i class="fas fa-user-cog" />
                </span>
                Settings
              </a>
            </li>
            <li v-if="isUserManager">
              <a
                href="#"
                @click="do_users"
              >
                <span class="icon has-icon-left">
                  <i class="fas fa-users" />
                </span>
                Users
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
        activeUser: {
          type: Object,
          default: null
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
        },
        onUsers: {
            type: Function,
            default: function () {
              return null
            }
        },      
        token: {
            type: String,
            default: ''
        },
        users: {
          type: Array,
          default: function () {
            return new Array
          }
        }
    },
    computed: {
      isUserManager: function () {
        if (this.activeUser && this.activeUser.type == 'UserManager') {
          return true
        }
        return false
      }
    },
    methods: {
        do_settings: function () {
          this.onSettings()
        },
        do_users: function () {
          this.onUsers()
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