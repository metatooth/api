<template>
  <section class="section">
    <table
      v-show="users.length"
      v-cloak
      class="table"
    >
      <thead>
        <tr>
          <th>E-mail</th>
          <th>Role</th>
          <th>Preferred Working Hours per Day</th>
          <th colspan="2">
            Actions
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="user in users" 
          :key="user.id"
          class="user-list"
        >
          <td>
            {{ user.email }}
          </td>
          <td>
            {{ user.type }}
          </td>
          <td>
            {{ user.preferred_working_seconds_per_day / 3600 }}
          </td>
          <td>
            <a
              class="button is-info"
              @click="edit(user)"
            >
              <span class="icon">
                <i class="fas fa-edit" />
              </span>
            </a>
          </td>
          <td>
            <a
              v-if="user.id != current.id"
              class="button is-warning"
              @click="remove(user)"
            >
              <span class="icon">
                <i class="fas fa-trash" />
              </span>
            </a>
          </td>
        </tr>
        <tr>
          <td>
            <input
              v-model.trim="email"
              class="input"
              type="text"
              placeholder="email"
            >
          </td>
          <td>
            <div class="select">
              <select v-model="type">
                <option value="User">
                  User
                </option>
                <option value="UserManager">
                  UserManager
                </option>
                <option value="Admin">
                  Admin
                </option>
              </select>
            </div>
          </td>

          <td>
            <input
              v-model.number="preferred_working_hours_per_day"
              class="input"
              type="number"
              placeholder="e.g., 6"
            >
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <div class="field is-horizontal">
              <div class="field-label">
                <label class="label">Password</label> 
              </div>
              <div class="field-body">
                <input
                  v-model.trim="password"
                  class="input"
                  type="password"
                  placeholder="At least 8 characters"
                >
              </div>
            </div>
          </td>




          <td style="text-align: center;">
            <a
              class="button is-primary"
              :disabled="!isComplete"
              @click="save()"
            >
              <span class="icon">
                <i class="fas fa-save" />
              </span>
            </a>
          </td>

          <td style="text-align: center;">
            <a
              class="button is-light"
              :disabled="!isComplete"
              @click="clearUser()"
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
  </section>
</template>

<script>
import usersService from '../api-services/users'

export default {
  props: {
    current: {
      type: Object,
      default: null
    },
    users: {
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
      email: '',
      type: 'User',
      preferred_working_hours_per_day: 6,
      password: '',
      errors: ''
    }
  },
  computed: {
    isComplete: function () {
      return (this.email.length != 0 && this.password.length > 7)
    }
  },
  methods: {
    clearUser: function () {
      this.email = ''
      this.type = 'User'
      this.preferred_working_hours_per_day = 6
      this.password = ''
    },
    edit: function(user) {
      this.onEdit(user)
    },
    remove: function (user) {
      const doomed_id = user.id

      // :TODO: 20190605 Terry: Don't allow a user to delete themselves. Delete user's tasks.
      // May need a backend process. User Manager doesn't have access to other's tasks.

      console.log('Removing ' + doomed_id)

      usersService.destroy(doomed_id, this.token)
        .then(response => {
          console.log(response)
          this.users.splice(this.users.indexOf(user), 1)
        }).catch(e => {
          console.log(e)
      })

    },
    save: function () {
      if (this.isComplete) {
      usersService.create({ email: this.email, type: this.type,
        preferred_working_seconds_per_day: this.preferred_working_hours_per_day * 3600, password: this.password}, this.token)
        .then(response => {
          console.log(response)
          console.log(response.data)
          this.users.push(response.data)
          this.clearUser()
        }).catch(error => {
          console.log(error)
        })
      } else {
        this.errors = 'Fix input errors. email and password must meet minimum lengths.'
      }
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
</style>