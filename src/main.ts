import * as db from './zapatos/src'
import * as s from './zapatos/schema'
import pool from './pgPool'


const allUsers = async () => {
  return await db.sql<s.users.SQL, s.users.Selectable[]>
    `select * from ${"users"}`
    .run(pool)
}

const insertUser = async (params: s.users.Insertable) => {
  const user = {
    name: params.name
  }
  return db.sql<s.users.SQL, s.users.Selectable[]>
  `
    INSERT INTO ${"users"} (${db.cols(user)})
    VALUES (${db.vals(user)}) RETURNING *
  `.run(pool)
}



const main = async () => {
  await insertUser({name: "João"})
  await insertUser({ name: "Zé" })
  return await allUsers()
}


main().then((d) => {
  console.log(d)
})
