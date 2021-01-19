import * as db from 'zapatos/db'

import type * as s from 'zapatos/schema'
import pool from './pgPool'


const allUsers = async () => {
  return await db.sql<s.users.SQL, s.users.Selectable[]>
    `select * from ${"users"}`
    .run(pool)
}

const insertUser = async (params: s.users.Insertable) => {
  return db.sql<s.users.SQL, s.users.Selectable[]>
  `
    INSERT INTO ${"users"} (${db.cols(params)})
    VALUES (${db.vals(params)}) RETURNING *
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
