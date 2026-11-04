package org.fiap.challenge_clyvo.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Cabecalho do Swagger. Titulo, descricao e versao vem do application.properties,
 * entao uma mudanca ali aparece no Swagger publicado depois do deploy da pipeline.
 */
@Configuration
public class ConfiguracaoDaDocumentacao {

    private static final String ESQUEMA_BEARER = "bearerAuth";

    @Bean
    public OpenAPI documentacaoDaApi(
            @Value("${springdoc.info.title:API Olli Pet}") String titulo,
            @Value("${springdoc.info.description:}") String descricao,
            @Value("${springdoc.info.version:v1}") String versao) {
        return new OpenAPI()
                .info(new Info().title(titulo).description(descricao).version(versao))
                // Habilita o botao "Authorize" para colar o token do /api/v1/auth/login.
                .components(new Components().addSecuritySchemes(ESQUEMA_BEARER, new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")))
                .addSecurityItem(new SecurityRequirement().addList(ESQUEMA_BEARER));
    }
}
