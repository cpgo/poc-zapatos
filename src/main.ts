import * as db from 'zapatos/db'

import type * as s from 'zapatos/schema'
import pool from './pgPool'


const allDeployments = async () => {
  return await db.sql<s.v2deployments.SQL, s.v2deployments.Selectable[]>
    `select * from ${"v2deployments"}`
    .run(pool)
}

// const allConfigs = async () => {
//   return await db.sql<s.cd_configurations.SQL, s.cd_configurations.Selectable[]>
//     `select * from ${"cd_configurations"}`
//     .run(pool)
// }

const insertUser = async (params: s.v2deployments.Insertable) => {
  return db.sql<s.v2deployments.SQL, s.v2deployments.Selectable[]>
  `
    INSERT INTO ${"v2deployments"} (${db.cols(params)})
    VALUES (${db.vals(params)}) RETURNING id
  `.run(pool)
}

const insertConfig = async (params: s.cd_configurations.Insertable) => {
  return await db.insert('cd_configurations', params, {returning: ['id']}).run(pool)
  // return db.sql<s.cd_configurations.SQL, s.cd_configurations.Selectable[]>
  // `
  //   INSERT INTO
  // `
}

const main = async () => {
  const config = await insertConfig({
    configuration_data: "",
    name: "my config",
    user_id: "cf86bab7-96de-4b58-a138-c970cce7fc48",
    workspace_id: "cf86bab7-96de-4b58-a138-c970cce7fc48"
  })
  const users = await insertUser(
    {
      author_id: "123123",
      callback_url: "123123",
      cd_configuration_id: config.id,
      circle_id: "cf86bab7-96de-4b58-a138-c970cce7fc48",
      default_circle: false,
      id: "cf86bab7-96de-4b58-a138-c970cce7fc48"
    })
  console.log(users.map(u => u.circle_id))
  return await allDeployments()
  // return await allConfigs()
}


main().then((d) => {
  console.log(d)
})
