<template>
  <section class="section">
    <nav class="level">
      <div class="level-item">
        <p class="title">
          Task Tracker
        </p>
      </div>
      <div
        v-if="token"
        class="level-item"
      >
        <a
          href="#"
          @click="do_settings"
        >
          <span class="icon has-icon-left">
            <i class="fas fa-user-cog" />
          </span>
          Settings
        </a>
      </div>
      <div
        v-if="isUserManager"
        class="level-item"
      >
        <a
          href="#"
          @click="do_users"
        >
          <span class="icon has-icon-left">
            <i class="fas fa-users" />
          </span>
          Users
        </a>
      </div>
      <div
        v-if="isUserManager"
        class="level-item"
      >
        <a
          href="#"
          @click="do_tasks"
        >
          <span class="icon has-icon-left">
            <i class="fas fa-file" />
          </span>
          Tasks
        </a>
      </div>
      <div
        v-if="token"
        class="level-item"
      >
        <a
          href="#"
          @click="signout"
        >
          <span class="icon has-icon-left">
            <i class="fas fa-sign-out-alt" />
          </span>
          Sign Out
        </a>
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
        onTasks: {
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
        do_tasks: function () {
          this.onTasks()
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