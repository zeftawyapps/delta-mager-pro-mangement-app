'use client';

import React from 'react';
import { WebsiteSection } from '../../types';

// ======================== Types ========================
export interface JockerPostSectionProps {
  section: WebsiteSection;
  lang: 'ar' | 'en';
}

// ======================== Component ========================
export default function JockerPostSection({
  section,
  lang,
}: JockerPostSectionProps) {
  const cfg = section.config || {};
  const imageUrl = cfg.imageUrl || '';
  const imageUrl2 = cfg.imageUrl2 || '';
  const imageCount = cfg.imageCount ?? 1;
  const fullScreen = cfg.fullScreen ?? false;
  const margin = fullScreen ? 0 : (cfg.margin ?? 16);

  // لو مفيش صورة، متعرضش حاجة
  if (!imageUrl) return null;

  const containerStyle: React.CSSProperties = fullScreen
    ? { marginLeft: 0, marginRight: 0, width: '100%' }
    : { marginLeft: margin, marginRight: margin };

  return (
    <section key={section.id} style={{ marginBottom: '2rem' }}>
      <div style={containerStyle} className="overflow-hidden">
        {imageCount === 2 && imageUrl2 ? (
          /* صورتين جنب بعض */
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="overflow-hidden rounded-[24px]">
              <img
                src={imageUrl}
                alt={section.title || (lang === 'ar' ? 'جوكر بوست' : 'Jocker Post')}
                className="w-full h-full object-cover hover:scale-105 transition-transform duration-700"
                style={{ minHeight: '200px', maxHeight: '400px' }}
              />
            </div>
            <div className="overflow-hidden rounded-[24px]">
              <img
                src={imageUrl2}
                alt={section.title || (lang === 'ar' ? 'جوكر بوست' : 'Jocker Post')}
                className="w-full h-full object-cover hover:scale-105 transition-transform duration-700"
                style={{ minHeight: '200px', maxHeight: '400px' }}
              />
            </div>
          </div>
        ) : (
          /* صورة واحدة */
          <div className="overflow-hidden rounded-[24px]">
            <img
              src={imageUrl}
              alt={section.title || (lang === 'ar' ? 'جوكر بوست' : 'Jocker Post')}
              className="w-full h-full object-cover hover:scale-105 transition-transform duration-700"
              style={{ 
                minHeight: fullScreen ? '300px' : '200px', 
                maxHeight: fullScreen ? '600px' : '400px',
                width: '100%'
              }}
            />
          </div>
        )}
      </div>
    </section>
  );
}
