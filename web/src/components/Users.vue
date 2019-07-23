<template>
  <section class="section">
    <table
      v-show="users.length"
      v-cloak
      class="table"
    >
      <thead>
        <tr>
          <th>Username</th>
          <th>Role</th>
          <th>Expected Daily Calories</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="user in users" 
          :key="user.id"
          class="user-list"
        >
          <td>
            {{ user.username }}
          </td>
          <td>
            {{ user.type }}
          </td>
          <td>
            {{ user.preferred_working_seconds_per_day }}
          </td>
          <td>
            <a
              class="button"
              @click="edit(user)"
            >
              <span class="icon">
                <i class="fas fa-edit" />
              </span>
            </a>
                &nbsp;
            <a
              class="button"
              @click="remove(user)"
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
      Add a user
    </p>
    <div class="field">
      <div class="control">
        <label>Username</label>
        <input
          v-model.trim="username"
          type="text"
          placeholder="Username"
        >
      </div>
    </div>
    <div class="field">
      <div class="control">
        <label>Role</label>
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
      </div>
    </div>
    <div class="field">
      <div class="control">
        <label>Expected Daily Calories</label>
        <input
          v-model.number="preferred_working_seconds_per_day"
          type="number"
        >
      </div>
    </div>
          
    <div class="field">
      <div class="control">
        <label>Password</label>
        <input
          v-model.trim="password"
          type="text"
          placeholder="At least 8 characters"
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
          @click="clearUser()"
        >Cancel</a>
      </div>
    </div>
  </section>
</template>

<script>
import UsersService from '../api-services/users'

export default {
  props: {
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
      username: '',
      type: 'User',
      preferred_working_seconds_per_day: 2000,
      password: '',
      errors: ''
    }
  },
  computed: {
    isComplete: function () {
      return (this.username.length != 0 && this.type.length != 0 && this.password.length > 7)
    }
  },
  methods: {
    clearUser: function () {
      this.username = ''
      this.type = 'User'
      this.preferred_working_seconds_per_day = 2000
      this.password = ''
    },
    edit: function(user) {
      this.onEdit(user)
    },
    remove: function (user) {
      const doomed_id = user.id
      this.users.splice(this.users.indexOf(user), 1)

      // :TODO: 20190605 Terry: Don't allow a user to delete themselves. Delete user's meals.
      // May needs a backend process. User Manager doesn't have access to other's meals.

      console.log('Removing ' + doomed_id)

      UsersService.destroy(doomed_id, this.token)
        .then(response => {
          console.log(response)
        }).catch(e => {
          console.log(e)
      })

    },
    save: function () {
      UsersService.create({ username: this.username, type: this.type,
        preferred_working_seconds_per_day: this.preferred_working_seconds_per_day, password: this.password}, this.token)
        .then(response => {
          console.log(response)
          console.log(response.data)
          this.users.push(response.data)
          this.clearUser()
        }).catch(error => {
          console.log(error)
        })
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