SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cd_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cd_configurations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    configuration_data text NOT NULL,
    user_id character varying NOT NULL,
    workspace_id character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    type character varying
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: v2components; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2components (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    deployment_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    component_id uuid NOT NULL,
    name character varying NOT NULL,
    image_url character varying NOT NULL,
    image_tag character varying NOT NULL,
    helm_url character varying NOT NULL,
    host_value character varying,
    gateway_name character varying,
    running boolean DEFAULT false NOT NULL,
    merged boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    manifests jsonb
);


--
-- Name: v2deployments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2deployments (
    id uuid NOT NULL,
    author_id character varying NOT NULL,
    callback_url character varying NOT NULL,
    circle_id character varying NOT NULL,
    current boolean DEFAULT false NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    cd_configuration_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    default_circle boolean NOT NULL,
    previous_deployment_id uuid,
    healthy boolean DEFAULT false NOT NULL,
    routed boolean DEFAULT false NOT NULL
);


--
-- Name: v2executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2executions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type character varying NOT NULL,
    deployment_id uuid NOT NULL,
    incoming_circle_id uuid,
    status character varying DEFAULT 'CREATED'::character varying NOT NULL,
    notification_status character varying DEFAULT 'NOT_SENT'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    finished_at timestamp without time zone
);


--
-- Name: cd_configurations PK_144238f578afbf2be3d2d089374; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cd_configurations
    ADD CONSTRAINT "PK_144238f578afbf2be3d2d089374" PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: v2deployments unique_deployments_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2deployments
    ADD CONSTRAINT unique_deployments_id PRIMARY KEY (id);


--
-- Name: v2executions unique_executions_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2executions
    ADD CONSTRAINT unique_executions_id PRIMARY KEY (id);


--
-- Name: v2components v2components_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2components
    ADD CONSTRAINT v2components_pkey PRIMARY KEY (id);


--
-- Name: IDX_254454041d6b147cfc40de8c90; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_254454041d6b147cfc40de8c90" ON public.v2deployments USING btree (current, circle_id, cd_configuration_id) WHERE current;


--
-- Name: index_components_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_components_id ON public.v2components USING btree (deployment_id);


--
-- Name: index_created_at_id_v2executions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_created_at_id_v2executions ON public.v2executions USING btree (created_at, id);


--
-- Name: index_deployments_id1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deployments_id1 ON public.v2executions USING btree (deployment_id);


--
-- Name: index_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name ON public.v2components USING btree (name);


--
-- Name: index_v2_deployments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_v2_deployments_id ON public.v2deployments USING btree (id);


--
-- Name: only_one_module_running; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX only_one_module_running ON public.v2components USING btree (running, name) WHERE running;


--
-- Name: v2deployments fk_v2cd_config_deployments; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2deployments
    ADD CONSTRAINT fk_v2cd_config_deployments FOREIGN KEY (cd_configuration_id) REFERENCES public.cd_configurations(id);


--
-- Name: v2components fk_v2deployments; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2components
    ADD CONSTRAINT fk_v2deployments FOREIGN KEY (deployment_id) REFERENCES public.v2deployments(id);


--
-- Name: v2executions fk_v2executions_v2deployments; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2executions
    ADD CONSTRAINT fk_v2executions_v2deployments FOREIGN KEY (deployment_id) REFERENCES public.v2deployments(id);


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20200819230751');
