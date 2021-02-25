-- migrate:up

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE public.cd_configurations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    configuration_data text NOT NULL,
    user_id character varying NOT NULL,
    workspace_id character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    type character varying
);

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

ALTER TABLE ONLY public.cd_configurations
    ADD CONSTRAINT "PK_144238f578afbf2be3d2d089374" PRIMARY KEY (id);

ALTER TABLE ONLY public.v2deployments
    ADD CONSTRAINT unique_deployments_id PRIMARY KEY (id);

ALTER TABLE ONLY public.v2executions
    ADD CONSTRAINT unique_executions_id PRIMARY KEY (id);

ALTER TABLE ONLY public.v2components
    ADD CONSTRAINT v2components_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX "IDX_254454041d6b147cfc40de8c90" ON public.v2deployments USING btree (current, circle_id, cd_configuration_id) WHERE current;

CREATE INDEX index_components_id ON public.v2components USING btree (deployment_id);

CREATE INDEX index_created_at_id_v2executions ON public.v2executions USING btree (created_at, id);

CREATE INDEX index_deployments_id1 ON public.v2executions USING btree (deployment_id);

CREATE INDEX index_name ON public.v2components USING btree (name);

CREATE INDEX index_v2_deployments_id ON public.v2deployments USING btree (id);

CREATE UNIQUE INDEX only_one_module_running ON public.v2components USING btree (running, name) WHERE running;

ALTER TABLE ONLY public.v2deployments
    ADD CONSTRAINT fk_v2cd_config_deployments FOREIGN KEY (cd_configuration_id) REFERENCES public.cd_configurations(id);

ALTER TABLE ONLY public.v2components
    ADD CONSTRAINT fk_v2deployments FOREIGN KEY (deployment_id) REFERENCES public.v2deployments(id);

ALTER TABLE ONLY public.v2executions
    ADD CONSTRAINT fk_v2executions_v2deployments FOREIGN KEY (deployment_id) REFERENCES public.v2deployments(id);

-- migrate:down

DROP TABLE cd_configurations, v2components, v2deployments, v2executions;
