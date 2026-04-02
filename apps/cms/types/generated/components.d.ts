import type { Schema, Struct } from '@strapi/strapi';

export interface AboutAboutComponent extends Struct.ComponentSchema {
  collectionName: 'components_about_about_components';
  info: {
    displayName: 'AboutComponent';
    icon: 'information';
  };
  attributes: {
    description: Schema.Attribute.Blocks & Schema.Attribute.Required;
    pfp: Schema.Attribute.Media<'images'> & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
    upper_title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'about.about-component': AboutAboutComponent;
    }
  }
}
