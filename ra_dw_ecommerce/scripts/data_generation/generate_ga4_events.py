#!/usr/bin/env python3
"""
GA4 Events Dataset Generator for Belle & Glow Cosmetics
Generates realistic Google Analytics 4 events that correspond to Shopify order data.
"""

import pandas as pd
import numpy as np
import json
import random
from datetime import datetime, timedelta
import uuid
from typing import Dict, List, Any
import math

class GA4EventsGenerator:
    def __init__(self):
        self.set_random_seed()
        
        # Load Shopify data
        self.load_shopify_data()
        
        # Initialize GA4 configuration
        self.stream_id = "2468013579"
        self.platform = "web"
        
        # Traffic source distributions
        self.traffic_sources = {
            'organic': 0.40,
            'direct': 0.25, 
            'social': 0.20,
            'email': 0.10,
            'paid': 0.05
        }
        
        # Device distributions
        self.device_categories = {
            'mobile': 0.65,
            'desktop': 0.30,
            'tablet': 0.05
        }
        
        # User journey patterns
        self.journey_patterns = {
            'converters': 0.30,
            'cart_abandoners': 0.20,
            'browsers': 0.35,
            'bouncers': 0.15
        }
        
        # UK Geographic data
        self.uk_locations = self.get_uk_locations()
        
        # Mobile device data
        self.mobile_devices = self.get_mobile_devices()
        
        # Page types for GA4
        self.page_types = [
            'home', 'category', 'product', 'cart', 'checkout', 
            'account', 'about', 'contact', 'blog'
        ]
        
        # Initialize storage
        self.events = []
        self.user_sessions = {}
        
    def set_random_seed(self):
        """Set random seed for reproducibility"""
        random.seed(42)
        np.random.seed(42)
        
    def load_shopify_data(self):
        """Load Shopify CSV data"""
        try:
            self.orders = pd.read_csv('/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/shopify/order.csv')
            self.customers = pd.read_csv('/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/shopify/customer.csv') 
            self.products = pd.read_csv('/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/shopify/product.csv')
            self.order_lines = pd.read_csv('/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/shopify/order_line.csv')
            self.product_variants = pd.read_csv('/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/shopify/product_variant.csv')
            
            # Convert datetime columns
            self.orders['created_at'] = pd.to_datetime(self.orders['created_at'])
            self.customers['created_at'] = pd.to_datetime(self.customers['created_at'])
            
            print(f"Loaded {len(self.orders)} orders, {len(self.customers)} customers, {len(self.products)} products")
            
        except Exception as e:
            print(f"Error loading Shopify data: {e}")
            raise
            
    def get_uk_locations(self) -> List[Dict]:
        """Return UK geographic locations"""
        return [
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'England', 'city': 'London'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'England', 'city': 'Manchester'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'England', 'city': 'Birmingham'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'England', 'city': 'Liverpool'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'England', 'city': 'Leeds'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'England', 'city': 'Sheffield'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'England', 'city': 'Bristol'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'Scotland', 'city': 'Edinburgh'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'Scotland', 'city': 'Glasgow'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'Wales', 'city': 'Cardiff'},
            {'continent': 'Europe', 'country': 'United Kingdom', 'region': 'Northern Ireland', 'city': 'Belfast'},
        ]
        
    def get_mobile_devices(self) -> List[Dict]:
        """Return mobile device configurations"""
        return [
            {'mobile_brand_name': 'Apple', 'mobile_model_name': 'iPhone 13'},
            {'mobile_brand_name': 'Apple', 'mobile_model_name': 'iPhone 14'},
            {'mobile_brand_name': 'Apple', 'mobile_model_name': 'iPhone 12'},
            {'mobile_brand_name': 'Samsung', 'mobile_model_name': 'Galaxy S22'},
            {'mobile_brand_name': 'Samsung', 'mobile_model_name': 'Galaxy S21'},
            {'mobile_brand_name': 'Google', 'mobile_model_name': 'Pixel 6'},
            {'mobile_brand_name': 'OnePlus', 'mobile_model_name': 'OnePlus 9'},
        ]
        
    def generate_user_pseudo_id(self) -> str:
        """Generate GA4 user pseudo ID"""
        return f"{random.randint(1000000000, 9999999999)}.{random.randint(1000000000, 9999999999)}"
        
    def generate_event_timestamp(self, base_time: datetime) -> int:
        """Convert datetime to GA4 timestamp (microseconds since epoch)"""
        return int(base_time.timestamp() * 1000000)
        
    def generate_device_info(self, category: str) -> Dict:
        """Generate device information"""
        if category == 'mobile':
            device = random.choice(self.mobile_devices)
            return {
                'category': 'mobile',
                'mobile_brand_name': device['mobile_brand_name'],
                'mobile_model_name': device['mobile_model_name'],
                'mobile_marketing_name': device['mobile_model_name'],
                'mobile_os_hardware_model': device['mobile_model_name'],
                'operating_system': 'iOS' if device['mobile_brand_name'] == 'Apple' else 'Android',
                'operating_system_version': '15.0' if device['mobile_brand_name'] == 'Apple' else '12.0',
                'vendor_id': str(uuid.uuid4())[:8],
                'advertising_id': str(uuid.uuid4()),
                'language': 'en-gb',
                'is_limited_ad_tracking': 'false',
                'time_zone_offset_seconds': 0,
                'browser': 'Safari' if device['mobile_brand_name'] == 'Apple' else 'Chrome',
                'browser_version': '15.0' if device['mobile_brand_name'] == 'Apple' else '96.0',
                'web_info': {
                    'browser': 'Safari' if device['mobile_brand_name'] == 'Apple' else 'Chrome',
                    'browser_version': '15.0' if device['mobile_brand_name'] == 'Apple' else '96.0',
                    'hostname': 'belleandglow.co.uk'
                }
            }
        elif category == 'desktop':
            browsers = ['Chrome', 'Safari', 'Firefox', 'Edge']
            browser = random.choice(browsers)
            return {
                'category': 'desktop',
                'operating_system': 'Windows' if browser == 'Edge' else random.choice(['macOS', 'Windows']),
                'operating_system_version': '10.15.7' if browser == 'Safari' else '10.0.19042',
                'language': 'en-gb',
                'time_zone_offset_seconds': 0,
                'browser': browser,
                'browser_version': '96.0' if browser == 'Chrome' else '15.0',
                'web_info': {
                    'browser': browser,
                    'browser_version': '96.0' if browser == 'Chrome' else '15.0',
                    'hostname': 'belleandglow.co.uk'
                }
            }
        else:  # tablet
            return {
                'category': 'tablet',
                'mobile_brand_name': 'Apple',
                'mobile_model_name': 'iPad',
                'operating_system': 'iOS',
                'operating_system_version': '15.0',
                'language': 'en-gb',
                'time_zone_offset_seconds': 0,
                'browser': 'Safari',
                'browser_version': '15.0',
                'web_info': {
                    'browser': 'Safari',
                    'browser_version': '15.0',
                    'hostname': 'belleandglow.co.uk'
                }
            }
            
    def generate_traffic_source(self, source_type: str) -> Dict:
        """Generate traffic source information"""
        if source_type == 'organic':
            sources = ['google', 'bing', 'yahoo']
            source = random.choice(sources)
            return {
                'source': source,
                'medium': 'organic',
                'campaign': '(not set)',
                'term': random.choice(['makeup', 'skincare', 'cosmetics', 'beauty', 'foundation', 'lipstick'])
            }
        elif source_type == 'direct':
            return {
                'source': '(direct)',
                'medium': '(none)',
                'campaign': '(not set)',
                'term': '(not set)'
            }
        elif source_type == 'social':
            platforms = ['facebook', 'instagram', 'tiktok', 'pinterest']
            platform = random.choice(platforms)
            return {
                'source': platform,
                'medium': 'social',
                'campaign': f'{platform}_organic',
                'content': 'post'
            }
        elif source_type == 'email':
            campaigns = ['newsletter', 'promo', 'welcome', 'cart_abandonment']
            campaign = random.choice(campaigns)
            return {
                'source': 'email',
                'medium': 'email',
                'campaign': campaign,
                'content': f'{campaign}_link'
            }
        else:  # paid
            return {
                'source': 'google',
                'medium': 'cpc',
                'campaign': 'beauty_products',
                'term': random.choice(['buy makeup', 'cosmetics online', 'skincare products']),
                'content': 'ad_group_1'
            }
            
    def generate_privacy_info(self) -> Dict:
        """Generate privacy information"""
        return {
            'analytics_storage': 'granted',
            'ads_storage': 'denied',
            'uses_transient_token': 'false'
        }
        
    def generate_user_properties(self, customer_email: str = None) -> Dict:
        """Generate user properties"""
        props = {
            'first_open_time': {'value': str(random.randint(1640995200, 1658361600))}  # 2022 range
        }
        
        if customer_email:
            props['customer_email'] = {'value': customer_email}
            props['customer_status'] = {'value': 'registered'}
        else:
            props['customer_status'] = {'value': 'guest'}
            
        return props
        
    def generate_user_ltv(self, customer_id: str = None) -> Dict:
        """Generate user lifetime value"""
        if customer_id:
            customer_data = self.customers[self.customers['id'] == int(customer_id)]
            if not customer_data.empty:
                total_spent = float(customer_data.iloc[0]['total_spent'])
                return {
                    'revenue': total_spent,
                    'currency': 'GBP'
                }
        
        return {
            'revenue': 0.0,
            'currency': 'GBP'
        }
        
    def generate_session_for_order(self, order_row: pd.Series) -> List[Dict]:
        """Generate a complete GA4 session that leads to a purchase"""
        session_events = []
        session_start_time = order_row['created_at'] - timedelta(minutes=random.randint(5, 45))
        
        # Get customer info
        customer_email = order_row['email'] if pd.notna(order_row['email']) else None
        customer_id = str(order_row['customer_id']) if pd.notna(order_row['customer_id']) else None
        
        # Generate user identifiers
        user_pseudo_id = self.generate_user_pseudo_id()
        user_id = customer_email if customer_email else None
        
        # Generate session characteristics
        device_category = np.random.choice(
            list(self.device_categories.keys()),
            p=list(self.device_categories.values())
        )
        traffic_source_type = np.random.choice(
            list(self.traffic_sources.keys()),
            p=list(self.traffic_sources.values())
        )
        
        device_info = self.generate_device_info(device_category)
        traffic_source = self.generate_traffic_source(traffic_source_type)
        geo_info = random.choice(self.uk_locations)
        privacy_info = self.generate_privacy_info()
        user_properties = self.generate_user_properties(customer_email)
        user_ltv = self.generate_user_ltv(customer_id)
        
        # Session start event
        session_start_timestamp = self.generate_event_timestamp(session_start_time)
        session_events.append(self.create_event(
            event_name='session_start',
            event_timestamp=session_start_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=[
                {'key': 'session_id', 'value': {'string_value': str(random.randint(1000000000, 9999999999))}},
                {'key': 'engaged_session_event', 'value': {'int_value': 1}}
            ]
        ))
        
        current_time = session_start_time
        
        # Home page view
        current_time += timedelta(seconds=random.randint(1, 3))
        session_events.append(self.create_page_view_event(
            current_time, user_id, user_pseudo_id, device_info, geo_info, 
            traffic_source, privacy_info, user_properties, user_ltv,
            page_title="Belle & Glow - Premium Cosmetics",
            page_location="https://belleandglow.co.uk/"
        ))
        
        # Browse products (2-5 product views)
        order_line_items = self.order_lines[self.order_lines['order_id'] == order_row['id']]
        products_in_order = order_line_items['product_id'].unique()
        
        # View some products (including ones that will be purchased)
        products_to_view = list(products_in_order) + random.sample(
            [p for p in self.products['id'].tolist() if p not in products_in_order], 
            random.randint(1, 3)
        )
        random.shuffle(products_to_view)
        
        for product_id in products_to_view[:random.randint(2, 5)]:
            current_time += timedelta(seconds=random.randint(10, 60))
            product_info = self.products[self.products['id'] == product_id].iloc[0]
            
            # Product page view
            session_events.append(self.create_page_view_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                page_title=f"{product_info['title']} - Belle & Glow",
                page_location=f"https://belleandglow.co.uk/products/{product_info['handle']}"
            ))
            
            # View item event
            current_time += timedelta(seconds=random.randint(2, 10))
            session_events.append(self.create_view_item_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                product_info
            ))
        
        # Add items to cart
        current_time += timedelta(seconds=random.randint(5, 30))
        for _, line_item in order_line_items.iterrows():
            product_info = self.products[self.products['id'] == line_item['product_id']].iloc[0]
            session_events.append(self.create_add_to_cart_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                line_item, product_info
            ))
            current_time += timedelta(seconds=random.randint(1, 5))
        
        # Begin checkout
        current_time += timedelta(seconds=random.randint(10, 120))
        session_events.append(self.create_begin_checkout_event(
            current_time, user_id, user_pseudo_id, device_info, geo_info,
            traffic_source, privacy_info, user_properties, user_ltv,
            order_row, order_line_items
        ))
        
        # Add shipping info
        current_time += timedelta(seconds=random.randint(30, 180))
        session_events.append(self.create_add_shipping_info_event(
            current_time, user_id, user_pseudo_id, device_info, geo_info,
            traffic_source, privacy_info, user_properties, user_ltv,
            order_row, order_line_items
        ))
        
        # Add payment info
        current_time += timedelta(seconds=random.randint(30, 120))
        session_events.append(self.create_add_payment_info_event(
            current_time, user_id, user_pseudo_id, device_info, geo_info,
            traffic_source, privacy_info, user_properties, user_ltv,
            order_row, order_line_items
        ))
        
        # Purchase event (use original order time)
        purchase_time = order_row['created_at']
        session_events.append(self.create_purchase_event(
            purchase_time, user_id, user_pseudo_id, device_info, geo_info,
            traffic_source, privacy_info, user_properties, user_ltv,
            order_row, order_line_items
        ))
        
        return session_events
        
    def create_event(self, event_name: str, event_timestamp: int, user_id: str, 
                    user_pseudo_id: str, device_info: Dict, geo_info: Dict,
                    traffic_source: Dict, privacy_info: Dict, user_properties: Dict,
                    user_ltv: Dict, event_params: List[Dict] = None, 
                    items: List[Dict] = None, event_value: float = None) -> Dict:
        """Create a GA4 event with all required fields"""
        
        event_date = datetime.fromtimestamp(event_timestamp / 1000000).strftime('%Y%m%d')
        
        event = {
            'event_date': event_date,
            'event_timestamp': str(event_timestamp),
            'event_name': event_name,
            'event_previous_timestamp': str(event_timestamp - random.randint(1000000, 10000000)),
            'event_value_in_usd': str(event_value) if event_value else None,
            'event_bundle_sequence_id': str(random.randint(1, 1000)),
            'event_server_timestamp_offset': str(random.randint(-1000000, 1000000)),
            'user_id': user_id,
            'user_pseudo_id': user_pseudo_id,
            'privacy_info': json.dumps(privacy_info),
            'user_properties': json.dumps(user_properties),
            'user_first_touch_timestamp': str(event_timestamp - random.randint(86400000000, 31536000000000)),  # 1 day to 1 year ago
            'user_ltv': json.dumps(user_ltv),
            'device': json.dumps(device_info),
            'geo': json.dumps(geo_info),
            'app_info': json.dumps({'id': 'belleandglow.co.uk', 'version': '1.0.0', 'install_store': None}),
            'traffic_source': json.dumps(traffic_source),
            'stream_id': self.stream_id,
            'platform': self.platform,
            'event_params': json.dumps(event_params) if event_params else json.dumps([]),
            'items': json.dumps(items) if items else json.dumps([]),
            'ecommerce': json.dumps({}) if items else json.dumps({})
        }
        
        return event
        
    def create_page_view_event(self, timestamp: datetime, user_id: str, user_pseudo_id: str,
                              device_info: Dict, geo_info: Dict, traffic_source: Dict,
                              privacy_info: Dict, user_properties: Dict, user_ltv: Dict,
                              page_title: str, page_location: str) -> Dict:
        """Create a page_view event"""
        event_timestamp = self.generate_event_timestamp(timestamp)
        
        event_params = [
            {'key': 'page_title', 'value': {'string_value': page_title}},
            {'key': 'page_location', 'value': {'string_value': page_location}},
            {'key': 'page_referrer', 'value': {'string_value': 'https://www.google.com/' if traffic_source.get('source') == 'google' else ''}},
            {'key': 'ga_session_id', 'value': {'int_value': random.randint(1000000000, 9999999999)}},
            {'key': 'ga_session_number', 'value': {'int_value': random.randint(1, 10)}},
            {'key': 'engaged_session_event', 'value': {'int_value': 1}}
        ]
        
        return self.create_event(
            event_name='page_view',
            event_timestamp=event_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=event_params
        )
        
    def create_view_item_event(self, timestamp: datetime, user_id: str, user_pseudo_id: str,
                              device_info: Dict, geo_info: Dict, traffic_source: Dict,
                              privacy_info: Dict, user_properties: Dict, user_ltv: Dict,
                              product_info: pd.Series) -> Dict:
        """Create a view_item event"""
        event_timestamp = self.generate_event_timestamp(timestamp)
        
        # Get product variant info
        variant_info = self.product_variants[self.product_variants['product_id'] == product_info['id']]
        if not variant_info.empty:
            variant = variant_info.iloc[0]
            price = float(variant['price'])
        else:
            price = random.uniform(10, 50)  # Fallback price
            
        items = [{
            'item_id': str(product_info['id']),
            'item_name': product_info['title'],
            'item_category': product_info['product_type'],
            'item_brand': 'Belle & Glow',
            'price': price,
            'currency': 'GBP',
            'quantity': 1
        }]
        
        event_params = [
            {'key': 'currency', 'value': {'string_value': 'GBP'}},
            {'key': 'value', 'value': {'double_value': price}},
            {'key': 'item_list_id', 'value': {'string_value': product_info['product_type'].lower()}},
            {'key': 'item_list_name', 'value': {'string_value': product_info['product_type']}}
        ]
        
        return self.create_event(
            event_name='view_item',
            event_timestamp=event_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=event_params,
            items=items,
            event_value=price
        )
        
    def create_add_to_cart_event(self, timestamp: datetime, user_id: str, user_pseudo_id: str,
                                device_info: Dict, geo_info: Dict, traffic_source: Dict,
                                privacy_info: Dict, user_properties: Dict, user_ltv: Dict,
                                line_item: pd.Series, product_info: pd.Series) -> Dict:
        """Create an add_to_cart event"""
        event_timestamp = self.generate_event_timestamp(timestamp)
        
        price = float(line_item['price'])
        quantity = int(line_item['quantity'])
        value = price * quantity
        
        items = [{
            'item_id': str(product_info['id']),
            'item_name': product_info['title'],
            'item_category': product_info['product_type'],
            'item_variant': line_item['name'],
            'item_brand': 'Belle & Glow',
            'price': price,
            'currency': 'GBP',
            'quantity': quantity
        }]
        
        event_params = [
            {'key': 'currency', 'value': {'string_value': 'GBP'}},
            {'key': 'value', 'value': {'double_value': value}}
        ]
        
        return self.create_event(
            event_name='add_to_cart',
            event_timestamp=event_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=event_params,
            items=items,
            event_value=value
        )
        
    def create_begin_checkout_event(self, timestamp: datetime, user_id: str, user_pseudo_id: str,
                                   device_info: Dict, geo_info: Dict, traffic_source: Dict,
                                   privacy_info: Dict, user_properties: Dict, user_ltv: Dict,
                                   order_row: pd.Series, order_line_items: pd.DataFrame) -> Dict:
        """Create a begin_checkout event"""
        event_timestamp = self.generate_event_timestamp(timestamp)
        
        items = []
        total_value = 0
        
        for _, line_item in order_line_items.iterrows():
            product_info = self.products[self.products['id'] == line_item['product_id']].iloc[0]
            price = float(line_item['price'])
            quantity = int(line_item['quantity'])
            value = price * quantity
            total_value += value
            
            items.append({
                'item_id': str(product_info['id']),
                'item_name': product_info['title'],
                'item_category': product_info['product_type'],
                'item_variant': line_item['name'],
                'item_brand': 'Belle & Glow',
                'price': price,
                'currency': 'GBP',
                'quantity': quantity
            })
        
        event_params = [
            {'key': 'currency', 'value': {'string_value': 'GBP'}},
            {'key': 'value', 'value': {'double_value': total_value}},
            {'key': 'coupon', 'value': {'string_value': ''}}
        ]
        
        return self.create_event(
            event_name='begin_checkout',
            event_timestamp=event_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=event_params,
            items=items,
            event_value=total_value
        )
        
    def create_add_shipping_info_event(self, timestamp: datetime, user_id: str, user_pseudo_id: str,
                                      device_info: Dict, geo_info: Dict, traffic_source: Dict,
                                      privacy_info: Dict, user_properties: Dict, user_ltv: Dict,
                                      order_row: pd.Series, order_line_items: pd.DataFrame) -> Dict:
        """Create an add_shipping_info event"""
        event_timestamp = self.generate_event_timestamp(timestamp)
        
        items = []
        total_value = 0
        
        for _, line_item in order_line_items.iterrows():
            product_info = self.products[self.products['id'] == line_item['product_id']].iloc[0]
            price = float(line_item['price'])
            quantity = int(line_item['quantity'])
            value = price * quantity
            total_value += value
            
            items.append({
                'item_id': str(product_info['id']),
                'item_name': product_info['title'],
                'item_category': product_info['product_type'],
                'item_variant': line_item['name'],
                'item_brand': 'Belle & Glow',
                'price': price,
                'currency': 'GBP',
                'quantity': quantity
            })
        
        shipping_tiers = ['standard', 'express', 'next_day']
        shipping_tier = random.choice(shipping_tiers)
        
        event_params = [
            {'key': 'currency', 'value': {'string_value': 'GBP'}},
            {'key': 'value', 'value': {'double_value': total_value}},
            {'key': 'shipping_tier', 'value': {'string_value': shipping_tier}},
            {'key': 'coupon', 'value': {'string_value': ''}}
        ]
        
        return self.create_event(
            event_name='add_shipping_info',
            event_timestamp=event_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=event_params,
            items=items,
            event_value=total_value
        )
        
    def create_add_payment_info_event(self, timestamp: datetime, user_id: str, user_pseudo_id: str,
                                     device_info: Dict, geo_info: Dict, traffic_source: Dict,
                                     privacy_info: Dict, user_properties: Dict, user_ltv: Dict,
                                     order_row: pd.Series, order_line_items: pd.DataFrame) -> Dict:
        """Create an add_payment_info event"""
        event_timestamp = self.generate_event_timestamp(timestamp)
        
        items = []
        total_value = 0
        
        for _, line_item in order_line_items.iterrows():
            product_info = self.products[self.products['id'] == line_item['product_id']].iloc[0]
            price = float(line_item['price'])
            quantity = int(line_item['quantity'])
            value = price * quantity
            total_value += value
            
            items.append({
                'item_id': str(product_info['id']),
                'item_name': product_info['title'],
                'item_category': product_info['product_type'],
                'item_variant': line_item['name'],
                'item_brand': 'Belle & Glow',
                'price': price,
                'currency': 'GBP',
                'quantity': quantity
            })
        
        payment_types = ['credit_card', 'debit_card', 'paypal', 'apple_pay']
        payment_type = random.choice(payment_types)
        
        event_params = [
            {'key': 'currency', 'value': {'string_value': 'GBP'}},
            {'key': 'value', 'value': {'double_value': total_value}},
            {'key': 'payment_type', 'value': {'string_value': payment_type}},
            {'key': 'coupon', 'value': {'string_value': ''}}
        ]
        
        return self.create_event(
            event_name='add_payment_info',
            event_timestamp=event_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=event_params,
            items=items,
            event_value=total_value
        )
        
    def create_purchase_event(self, timestamp: datetime, user_id: str, user_pseudo_id: str,
                             device_info: Dict, geo_info: Dict, traffic_source: Dict,
                             privacy_info: Dict, user_properties: Dict, user_ltv: Dict,
                             order_row: pd.Series, order_line_items: pd.DataFrame) -> Dict:
        """Create a purchase event"""
        event_timestamp = self.generate_event_timestamp(timestamp)
        
        items = []
        
        for _, line_item in order_line_items.iterrows():
            product_info = self.products[self.products['id'] == line_item['product_id']].iloc[0]
            price = float(line_item['price'])
            quantity = int(line_item['quantity'])
            
            items.append({
                'item_id': str(product_info['id']),
                'item_name': product_info['title'],
                'item_category': product_info['product_type'],
                'item_variant': line_item['name'],
                'item_brand': 'Belle & Glow',
                'price': price,
                'currency': 'GBP',
                'quantity': quantity
            })
        
        total_value = float(order_row['total_price'])
        
        event_params = [
            {'key': 'currency', 'value': {'string_value': 'GBP'}},
            {'key': 'value', 'value': {'double_value': total_value}},
            {'key': 'transaction_id', 'value': {'string_value': str(order_row['id'])}},
            {'key': 'tax', 'value': {'double_value': float(order_row['total_tax'])}},
            {'key': 'shipping', 'value': {'double_value': 0.0}},
            {'key': 'coupon', 'value': {'string_value': ''}}
        ]
        
        return self.create_event(
            event_name='purchase',
            event_timestamp=event_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=event_params,
            items=items,
            event_value=total_value
        )
        
    def generate_non_converting_session(self, base_date: datetime, journey_type: str) -> List[Dict]:
        """Generate non-converting sessions (browsers, cart abandoners, bouncers)"""
        session_events = []
        
        # Random session start time around the base date
        session_start_time = base_date + timedelta(
            hours=random.randint(-12, 12),
            minutes=random.randint(0, 59)
        )
        
        # Generate user identifiers (mostly anonymous)
        user_pseudo_id = self.generate_user_pseudo_id()
        user_id = None  # Most non-converting users are anonymous
        
        # Occasionally assign a known customer for returning visitors
        if random.random() < 0.1:  # 10% chance
            customer = self.customers.sample(1).iloc[0]
            user_id = customer['email']
        
        # Generate session characteristics
        device_category = np.random.choice(
            list(self.device_categories.keys()),
            p=list(self.device_categories.values())
        )
        traffic_source_type = np.random.choice(
            list(self.traffic_sources.keys()),
            p=list(self.traffic_sources.values())
        )
        
        device_info = self.generate_device_info(device_category)
        traffic_source = self.generate_traffic_source(traffic_source_type)
        geo_info = random.choice(self.uk_locations)
        privacy_info = self.generate_privacy_info()
        user_properties = self.generate_user_properties(user_id)
        user_ltv = self.generate_user_ltv()
        
        # Session start event
        session_start_timestamp = self.generate_event_timestamp(session_start_time)
        session_events.append(self.create_event(
            event_name='session_start',
            event_timestamp=session_start_timestamp,
            user_id=user_id,
            user_pseudo_id=user_pseudo_id,
            device_info=device_info,
            geo_info=geo_info,
            traffic_source=traffic_source,
            privacy_info=privacy_info,
            user_properties=user_properties,
            user_ltv=user_ltv,
            event_params=[
                {'key': 'session_id', 'value': {'string_value': str(random.randint(1000000000, 9999999999))}},
                {'key': 'engaged_session_event', 'value': {'int_value': 1 if journey_type != 'bouncers' else 0}}
            ]
        ))
        
        current_time = session_start_time
        
        if journey_type == 'bouncers':
            # Just home page view and exit
            current_time += timedelta(seconds=random.randint(1, 3))
            session_events.append(self.create_page_view_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                page_title="Belle & Glow - Premium Cosmetics",
                page_location="https://belleandglow.co.uk/"
            ))
            
        elif journey_type == 'browsers':
            # Home page + some product views (simplified for speed)
            current_time += timedelta(seconds=random.randint(1, 3))
            session_events.append(self.create_page_view_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                page_title="Belle & Glow - Premium Cosmetics",
                page_location="https://belleandglow.co.uk/"
            ))
            
            # View 1-2 products only (reduced for speed)
            num_products = random.randint(1, 2)
            for i in range(num_products):
                product_info = self.products.sample(1).iloc[0]
                current_time += timedelta(seconds=random.randint(10, 60))
                
                # Product page view
                session_events.append(self.create_page_view_event(
                    current_time, user_id, user_pseudo_id, device_info, geo_info,
                    traffic_source, privacy_info, user_properties, user_ltv,
                    page_title=f"{product_info['title']} - Belle & Glow",
                    page_location=f"https://belleandglow.co.uk/products/{product_info['handle']}"
                ))
                
                # View item event
                current_time += timedelta(seconds=random.randint(2, 15))
                session_events.append(self.create_view_item_event(
                    current_time, user_id, user_pseudo_id, device_info, geo_info,
                    traffic_source, privacy_info, user_properties, user_ltv,
                    product_info
                ))
                
        elif journey_type == 'cart_abandoners':
            # Simplified cart abandonment flow
            current_time += timedelta(seconds=random.randint(1, 3))
            session_events.append(self.create_page_view_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                page_title="Belle & Glow - Premium Cosmetics",
                page_location="https://belleandglow.co.uk/"
            ))
            
            # Add only 1 product to cart (simplified)
            product_info = self.products.sample(1).iloc[0]
            current_time += timedelta(seconds=random.randint(10, 60))
            
            # Product page view
            session_events.append(self.create_page_view_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                page_title=f"{product_info['title']} - Belle & Glow",
                page_location=f"https://belleandglow.co.uk/products/{product_info['handle']}"
            ))
            
            # View item event
            current_time += timedelta(seconds=random.randint(2, 15))
            session_events.append(self.create_view_item_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                product_info
            ))
            
            # Add to cart event
            current_time += timedelta(seconds=random.randint(5, 30))
            
            # Create simple mock line item
            mock_line_item = pd.Series({
                'product_id': product_info['id'],
                'name': 'Default',
                'price': random.uniform(10, 50),
                'quantity': 1
            })
            
            session_events.append(self.create_add_to_cart_event(
                current_time, user_id, user_pseudo_id, device_info, geo_info,
                traffic_source, privacy_info, user_properties, user_ltv,
                mock_line_item, product_info
            ))
        
        return session_events
        
    def generate_dataset(self) -> pd.DataFrame:
        """Generate the complete GA4 events dataset"""
        print("Starting GA4 events generation...")
        
        # Generate converting sessions (one per order)
        print(f"Generating converting sessions for {len(self.orders)} orders...")
        for idx, (_, order_row) in enumerate(self.orders.iterrows()):
            if idx % 1000 == 0:
                print(f"  Processed {idx} orders...")
            
            session_events = self.generate_session_for_order(order_row)
            self.events.extend(session_events)
        
        print(f"Generated {len(self.events)} events from converting sessions")
        
        # Generate non-converting sessions (2x the volume for faster processing)
        target_non_converting = len(self.orders) * 2
        print(f"Generating {target_non_converting} non-converting sessions...")
        
        # Get date range from orders
        min_date = self.orders['created_at'].min()
        max_date = self.orders['created_at'].max()
        
        # Pre-generate random dates and journey types for efficiency
        date_range_days = (max_date - min_date).days
        random_days = np.random.randint(0, date_range_days + 1, target_non_converting)
        journey_types = np.random.choice(
            ['browsers', 'cart_abandoners', 'bouncers'],
            size=target_non_converting,
            p=[0.50, 0.29, 0.21]
        )
        
        for i in range(target_non_converting):
            if i % 500 == 0:
                print(f"  Generated {i} non-converting sessions...")
            
            # Use pre-generated random values
            random_date = min_date + timedelta(days=int(random_days[i]))
            journey_type = journey_types[i]
            
            session_events = self.generate_non_converting_session(random_date, journey_type)
            self.events.extend(session_events)
        
        print(f"Total events generated: {len(self.events)}")
        
        # Convert to DataFrame
        events_df = pd.DataFrame(self.events)
        
        # Sort by timestamp
        events_df['event_timestamp'] = events_df['event_timestamp'].astype(int)
        events_df = events_df.sort_values('event_timestamp')
        
        # Reset index
        events_df = events_df.reset_index(drop=True)
        
        print("GA4 events dataset generation complete!")
        return events_df
        
    def save_dataset(self, events_df: pd.DataFrame, output_path: str):
        """Save the events dataset to CSV"""
        # Ensure ga4 directory exists
        ga4_dir = '/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/ga4'
        import os
        os.makedirs(ga4_dir, exist_ok=True)
        
        # Save to CSV
        events_df.to_csv(output_path, index=False)
        print(f"Dataset saved to: {output_path}")
        print(f"Total rows: {len(events_df)}")
        print(f"Date range: {events_df['event_date'].min()} to {events_df['event_date'].max()}")
        print(f"Unique events: {events_df['event_name'].value_counts().to_dict()}")

def main():
    """Main execution function"""
    print("Belle & Glow GA4 Events Dataset Generator")
    print("=" * 50)
    
    generator = GA4EventsGenerator()
    events_df = generator.generate_dataset()
    
    output_path = '/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/ga4/events.csv'
    generator.save_dataset(events_df, output_path)
    
    print("\nDataset generation completed successfully!")
    print(f"You can now use this as dbt seed data: dbt seed --select ga4.events")

if __name__ == "__main__":
    main()